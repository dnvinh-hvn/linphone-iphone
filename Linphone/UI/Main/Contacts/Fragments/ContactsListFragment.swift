/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import SwiftUI
import linphonesw

struct ContactsListFragment: View {
	
	@ObservedObject var contactsManager = ContactsManager.shared
	
	@EnvironmentObject var contactsListViewModel: ContactsListViewModel
	
	@Binding var showingSheet: Bool
	
    var startCallFunc: (_ addr: Address) -> Void
	
	var body: some View {
		ForEach(Array(contactsManager.avatarListModel.enumerated()), id: \.element.id) { index, contactAvatarModel in
			ContactRow(contactAvatarModel: contactAvatarModel, index: index, showingSheet: $showingSheet, startCallFunc: startCallFunc)
		}
	}
}

struct ContactRow: View {
	@ObservedObject var contactsManager = ContactsManager.shared
	
	@EnvironmentObject var contactsListViewModel: ContactsListViewModel
	
	@ObservedObject var contactAvatarModel: ContactAvatarModel
	
	let index: Int
	
	@Binding var showingSheet: Bool
	
	var startCallFunc: (_ addr: Address) -> Void
	
	var body: some View {
		HStack {
            Avatar(contactAvatarModel: contactAvatarModel, avatarSize: 50)
            
            VStack(alignment: .leading) {
                Text(contactAvatarModel.name)
                    .text_style(fontSize: 16, fontWeight: 500, fontColor: .black)
                
                Text(contactAvatarModel.organization.isEmpty ? "-" : contactAvatarModel.organization)
                    .text_style(fontSize: 16, fontWeight: 500, fontColor: .blue)
                
                Text(contactAvatarModel.jobTitle.isEmpty ? "-" : contactAvatarModel.jobTitle)
                    .text_style(fontSize: 14, fontWeight: 500, fontColor: .gray)
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
		.buttonStyle(.borderless)
		.listRowInsets(EdgeInsets())
		.listRowSeparator(.hidden)
		.background(.white)
		.onTapGesture {
            if SharedMainViewModel.shared.indexView == 0 {
                withAnimation {
                    SharedMainViewModel.shared.displayedFriend = contactAvatarModel
                }
            }
            
			if contactAvatarModel.friend != nil
				&& contactAvatarModel.friend!.address != nil {
				startCallFunc(contactAvatarModel.friend!.address!)
			}
		}
		.onLongPressGesture(minimumDuration: 0.2) {
            if SharedMainViewModel.shared.indexView == 0 {
                contactsListViewModel.selectedFriend = contactAvatarModel
                showingSheet.toggle()
            }
		}
	}
}

#Preview {
    ContactsListFragment(showingSheet: .constant(false), startCallFunc: {_ in })
}
