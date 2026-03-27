//
//  ContactHeader.swift
//  LinphoneApp
//
//  Created by hvn-dyan on 24/3/26.
//

import SwiftUI

struct ContactHeader: View {
    @ObservedObject var departmentViewModel: DepartmentViewModel
    var body: some View {
        HStack {
            if departmentViewModel.currentSelectDept.isEmpty {
                tabItem(
                    isRoot: true,
                    title: "",
                    isCurrent: true,
                    onTap: {}
                )
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(
                                Array(
                                    departmentViewModel.currentSelectDept
                                        .enumerated()
                                ),
                                id: \.element.deptCd
                            ) { index, dept in
                                let isCurrent =
                                    index
                                    == (departmentViewModel.currentSelectDept
                                        .count
                                        - 1)
                                tabItem(
                                    title: dept.deptNm,
                                    isCurrent: isCurrent,
                                ) {
                                    departmentViewModel.popToDept(at: index)
                                }
                                .id(dept.deptCd)
                            }
                        }
                    }
                    .onAppear {
                        if let last = departmentViewModel.currentSelectDept.last
                        {
                            DispatchQueue.main.async {
                                withAnimation {
                                    proxy.scrollTo(
                                        last.deptCd,
                                        anchor: .trailing
                                    )
                                }
                            }
                        }
                    }
                    .onChange(of: departmentViewModel.currentSelectDept.count) {
                        _ in
                        if let last = departmentViewModel.currentSelectDept.last
                        {
                            DispatchQueue.main.async {
                                withAnimation {
                                    proxy.scrollTo(
                                        last.deptCd,
                                        anchor: .trailing
                                    )
                                }
                            }
                        }
                    }
                }
            }

            Spacer()

        }.padding(.horizontal, 16).frame(maxWidth: .infinity).overlay(
            alignment: .bottom
        ) {
            Rectangle()
                .fill(
                    Color.gray.opacity(0.5)
                )
                .frame(height: 1)

        }
    }

    @ViewBuilder
    private func tabItem(
        isRoot: Bool = false,
        title: String,
        isCurrent: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        if isRoot {
            Image(systemName: "house").resizable().frame(
                width: 25,
                height: 25
            ).padding(.bottom, 6)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(
                            Color.orangeMain500
                        )
                        .frame(height: 3)
                }
        } else {
            HStack {
                Button(action: onTap) {
                    Text(title)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .foregroundStyle(
                            isCurrent ? Color.orangeMain500 : Color.primary
                        )
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(
                                    isCurrent
                                        ? Color.orangeMain500 : Color.transparentColor
                                )
                                .frame(height: 3)
                        }
                }
                .buttonStyle(.plain)
                Image(systemName: "chevron.right").resizable().frame(
                    width: 8,
                    height: 12
                )
            }

        }
    }
}

#Preview {
    ContactHeader(departmentViewModel: DepartmentViewModel())
}
