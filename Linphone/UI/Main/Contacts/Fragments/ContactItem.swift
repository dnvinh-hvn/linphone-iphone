//
//  ContactItem.swift
//  LinphoneApp
//
//  Created by hvn-dyan on 23/3/26.
//

import SwiftUI

struct ContactItem: View {
    var deptUser: DeptUserItem? = nil
    var onTap: (() -> Void)?
    
    private var contactAvatarModel: ContactAvatarModel {
        ContactAvatarModel(
            friend: nil,
            name: deptUser?.userNm ?? "",
            address: "",
            withPresence: false
        )
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack {
                Avatar(contactAvatarModel: contactAvatarModel, avatarSize: 50)

                VStack(alignment: .leading) {
                    Text(deptUser?.userNm ?? "").text_style(
                        fontSize: 16,
                        fontWeight: 500,
                        fontColor: .black
                    )
                    Text(deptUser?.deptNm ?? "-").text_style(
                        fontSize: 16,
                        fontWeight: 500,
                        fontColor: .blue
                    )
                    Text(deptUser?.duty ?? "-").text_style(
                        fontSize: 14,
                        fontWeight: 500,
                        fontColor: .gray
                    )
                }

                Spacer()

                Image(systemName: "message")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(.trailing, 8)

                Image(systemName: "phone")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .padding(8)
            .background(Color.white)
            .padding(.horizontal, 8)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContactItem()
}
