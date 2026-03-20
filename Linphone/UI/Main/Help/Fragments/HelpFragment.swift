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

struct HelpFragment: View {
	
	@StateObject private var helpViewModel = HelpViewModel()
	
	@Binding var isShowHelpFragment: Bool
	
	var showAssistant: Bool {
		(CoreContext.shared.coreIsStarted && CoreContext.shared.accounts.isEmpty)
		|| SharedMainViewModel.shared.displayProfileMode
	}
	
	var body: some View {
		NavigationView {
			ZStack {
                VStack(spacing: 1) {
                    if !showAssistant {
                        Rectangle()
                            .foregroundColor(Color.orangeMain500)
                            .edgesIgnoringSafeArea(.top)
                            .frame(height: 0)
                    }
                    
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
                                withAnimation {
                                    isShowHelpFragment = false
                                }
                            }
                        
                        Text("help_title")
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
                            VStack(spacing: 20) {
                                if let urlString = CorePreferences.themeAboutPictureUrl,
                                   let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
                                        case .failure:
                                            EmptyView()
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    EmptyView()
                                }
                                Text("help_about_title")
                                    .default_text_style_800(styleSize: 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 5)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .background(Color.gray100)
                    }
                    .background(Color.gray100)
                }
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.navigationTitle("")
		.navigationBarHidden(true)
	}
}
