//
//  DepartmentItem.swift
//  LinphoneApp
//
//  Created by hvn-dyan on 25/3/26.
//

import SwiftUI

struct DepartmentItem: View {
    let title: String
    let totalContact: Int
    var onTap: (() -> Void)?

    var body: some View {
        VStack {
            HStack {
                Text("\(title) (\(totalContact))")
                Spacer()
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 8, height: 12)
                    .foregroundStyle(.green)
            }
            .padding()
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
            }
        }
        .contentShape(Rectangle()) 
        .onTapGesture {
            onTap?()
        }
    }
}
#Preview {
    DepartmentItem(title: "APPPPPP", totalContact: 10)
}
