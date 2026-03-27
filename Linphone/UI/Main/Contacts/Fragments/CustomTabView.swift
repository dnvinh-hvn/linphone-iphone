//
//  CustomTabView.swift
//  LinphoneApp
//
//  Created by hvn-dyan on 23/3/26.
//

import SwiftUI

struct CustomTabView<InternalContact: View, PersonalContact: View>: View {
    let tab1Content: InternalContact
    let tab2Content: PersonalContact
    @ObservedObject var departmentViewModel: DepartmentViewModel
    @Binding var searchText: String

    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                tabItem(title: "사내 연락처", index: 0)
                tabItem(title: "개인 연락처", index: 1)
            }
            .background(Color.gray.opacity(0.2))
            .cornerRadius(6)
            .padding()
            if selectedTab == 0 {
                HStack {
                    Spacer()
//                    TextField("Search", text: $searchText)
//                        .padding(10)
//                        .padding(.trailing, 35)
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(10)
//                        .overlay(alignment: .trailing) {
//                            Image(systemName: "magnifyingglass")
//                                .foregroundColor(.gray)
//                                .padding(.trailing, 10)
//                        }
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.gray, lineWidth: 1)
//                        )
//                        .padding(.horizontal, 16)

                    Button {
                        departmentViewModel.resetToRoot()
                    } label: {
                        Image(systemName: "house")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(.trailing, 16)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }

            if searchText.isEmpty && selectedTab == 0 {
                ContactHeader(departmentViewModel: departmentViewModel)
            }

            Group {
                if selectedTab == 0 {
                    tab1Content
                } else {
                    tab2Content
                }
            }

            Spacer()
        }
    }

    private func tabItem(title: String, index: Int) -> some View {
        Button(action: {
            selectedTab = index
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(selectedTab == index ? Color.green : Color.clear)
                .foregroundColor(selectedTab == index ? .white : .black)
        }
    }
}

#Preview {
    CustomTabView(
        tab1Content: Text("Danh sách nội bộ"),
        tab2Content: VStack {
            Text("Danh sách cá nhân")
            Text("More UI")
        },
        departmentViewModel: DepartmentViewModel(),
        searchText: .constant("")
    )
}
