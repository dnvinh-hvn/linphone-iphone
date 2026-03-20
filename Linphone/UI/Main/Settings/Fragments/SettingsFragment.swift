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
	@ObservedObject private var dndManager = DNDManager.shared

	@Binding var isShowSettingsFragment: Bool

	@State var securityIsOpen: Bool = false
	@State var callsIsOpen: Bool = false
	@State var conversationsIsOpen: Bool = false
	@State var contactsIsOpen: Bool = false
	@State var meetingsIsOpen: Bool = false
	@State var networkIsOpen: Bool = false
	@State var userInterfaceIsOpen: Bool = false

	// Local date bindings for the time pickers
	private var scheduleStartDate: Binding<Date> {
		Binding(
			get: { DNDManager.minutesToDate(dndManager.scheduleStartMinutes) },
			set: { dndManager.scheduleStartMinutes = DNDManager.dateToMinutes($0) }
		)
	}
	private var scheduleEndDate: Binding<Date> {
		Binding(
			get: { DNDManager.minutesToDate(dndManager.scheduleEndMinutes) },
			set: { dndManager.scheduleEndMinutes = DNDManager.dateToMinutes($0) }
		)
	}

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
						VStack(spacing: 12) {

							// MARK: - General
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

							// MARK: - Do Not Disturb
							VStack(alignment: .leading, spacing: 0) {

								// Section header
								Text("settings_dnd_section_title")
									.default_text_style_orange_800(styleSize: 13)
									.padding(.horizontal, 20)
									.padding(.top, 16)
									.padding(.bottom, 8)

								VStack(spacing: 0) {

									// --- Manual toggle ---
									Toggle(isOn: $dndManager.isManuallyEnabled) {
										VStack(alignment: .leading, spacing: 2) {
											Text("settings_dnd_enable_now_title")
												.default_text_style_700(styleSize: 15)
											if dndManager.isManuallyEnabled {
												Text("settings_dnd_active_subtitle")
													.default_text_style(styleSize: 12)
													.foregroundColor(Color.orangeMain500)
											}
										}
									}
									.padding(.horizontal, 20)
									.padding(.vertical, 16)

									Divider().padding(.leading, 20)

									// --- Schedule toggle ---
									Toggle("settings_dnd_schedule_title", isOn: $dndManager.isScheduleEnabled)
                                        .disabled(dndManager.isManuallyEnabled)
										.default_text_style_700(styleSize: 15)
										.padding(.horizontal, 20)
										.padding(.vertical, 16)

									// --- Time pickers (visible when schedule is on) ---
									if dndManager.isScheduleEnabled && !dndManager.isManuallyEnabled {
										Divider().padding(.leading, 20)

										HStack {
											Text("settings_dnd_schedule_start_title")
												.default_text_style_700(styleSize: 15)
											Spacer()
											DatePicker("", selection: scheduleStartDate, displayedComponents: .hourAndMinute)
												.labelsHidden()
										}
										.padding(.horizontal, 20)
										.padding(.vertical, 12)

										Divider().padding(.leading, 20)

										HStack {
											Text("settings_dnd_schedule_end_title")
												.default_text_style_700(styleSize: 15)
											Spacer()
											DatePicker("", selection: scheduleEndDate, displayedComponents: .hourAndMinute)
												.labelsHidden()
										}
										.padding(.horizontal, 20)
										.padding(.vertical, 12)

										Divider().padding(.leading, 20)

										// Status hint
										HStack(spacing: 6) {
											Image(systemName: dndManager.isCurrentlyActive ? "moon.fill" : "moon")
												.foregroundColor(dndManager.isCurrentlyActive ? Color.orangeMain500 : .gray)
											Text(dndManager.isCurrentlyActive
												 ? String(localized: "settings_dnd_status_active")
												 : scheduleRangeLabel)
												.default_text_style(styleSize: 12)
												.foregroundColor(dndManager.isCurrentlyActive ? Color.orangeMain500 : .gray)
										}
										.padding(.horizontal, 20)
										.padding(.vertical, 10)
									}
								}
								.background(.white)
								.cornerRadius(15)
								.padding(.bottom, 4)
							}
						}
						.padding(.horizontal, 12)
						.padding(.vertical, 12)
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

	private var scheduleRangeLabel: String {
		let fmt = DateFormatter()
		fmt.timeStyle = .short
		fmt.dateStyle = .none
		let start = fmt.string(from: DNDManager.minutesToDate(dndManager.scheduleStartMinutes))
		let end   = fmt.string(from: DNDManager.minutesToDate(dndManager.scheduleEndMinutes))
		return String(format: NSLocalizedString("settings_dnd_schedule_range", comment: ""), start, end)
	}
}
