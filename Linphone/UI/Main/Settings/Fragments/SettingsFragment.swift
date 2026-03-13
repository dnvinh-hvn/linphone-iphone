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
import UniformTypeIdentifiers

struct SettingsFragment: View {
	
	@StateObject private var settingsViewModel = SettingsViewModel()
	
	@Binding var isShowSettingsFragment: Bool
	
	@State var securityIsOpen: Bool = false
	@State var callsIsOpen: Bool = false
	@State var conversationsIsOpen: Bool = false
	@State var contactsIsOpen: Bool = false
	@State var meetingsIsOpen: Bool = false
	@State var networkIsOpen: Bool = false
	@State var userInterfaceIsOpen: Bool = false
	
	var body: some View {
		NavigationView {
			ZStack {
				VStack(spacing: 1) {
					Rectangle()
						.foregroundColor(Color.orangeMain500)
						.edgesIgnoringSafeArea(.top)
						.frame(height: 0)
					
					HStack {
						Image("caret-left")
							.renderingMode(.template)
							.resizable()
							.foregroundStyle(Color.orangeMain500)
							.frame(width: 25, height: 25, alignment: .leading)
							.padding(.all, 10)
							.padding(.top, 4)
							.padding(.leading, -10)
							.onTapGesture {
								settingsViewModel.saveChangesWhenLeaving()
								withAnimation {
									if isShowSettingsFragment {
										isShowSettingsFragment = false
									}
								}
							}
						
						Text("settings_title")
							.default_text_style_orange_800(styleSize: 16)
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(.top, 4)
							.lineLimit(1)
						
						Spacer()
					}
					.frame(maxWidth: .infinity)
					.frame(height: 50)
					.padding(.horizontal)
					.padding(.bottom, 4)
					.background(.white)
					
					ScrollView {
						VStack(spacing: 0) {
							
							VStack(spacing: 0) {
								VStack(spacing: 30) {
									Toggle("settings_calls_auto_record_title", isOn: $settingsViewModel.autoRecord)
												.default_text_style_700(styleSize: 15)
									}
									.padding(.vertical, 30)
									.padding(.horizontal, 20)
								}
								.background(.white)
								.cornerRadius(15)
								.zIndex(-2)
								.transition(.move(edge: .top))
						
						}
						.background(Color.gray100)
					}
					.background(Color.gray100)
				}
				.background(Color.gray100)
			}
			.navigationTitle("")
			.navigationBarHidden(true)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
