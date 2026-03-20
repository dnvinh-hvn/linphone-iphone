/*
 * DNDManager.swift
 *
 * Manages Do Not Disturb state.
 * Two modes:
 *   - Manual: enabled from now until the user turns it off.
 *   - Scheduled: active daily between a start and end time (overnight ranges supported).
 */

import Foundation
import Combine

class DNDManager: ObservableObject {

	static let shared = DNDManager()

	// MARK: - Persisted state

	@Published var isManuallyEnabled: Bool {
		didSet { UserDefaults.standard.set(isManuallyEnabled, forKey: "dnd_manual_enabled") }
	}

	@Published var isScheduleEnabled: Bool {
		didSet { UserDefaults.standard.set(isScheduleEnabled, forKey: "dnd_schedule_enabled") }
	}

	/// Minutes since midnight for the schedule start (0 – 1439).
	@Published var scheduleStartMinutes: Int {
		didSet { UserDefaults.standard.set(scheduleStartMinutes, forKey: "dnd_schedule_start") }
	}

	/// Minutes since midnight for the schedule end (0 – 1439).
	@Published var scheduleEndMinutes: Int {
		didSet { UserDefaults.standard.set(scheduleEndMinutes, forKey: "dnd_schedule_end") }
	}

	// MARK: - Init

	private init() {
		let ud = UserDefaults.standard
		isManuallyEnabled   = ud.bool(forKey: "dnd_manual_enabled")
		isScheduleEnabled   = ud.bool(forKey: "dnd_schedule_enabled")
		scheduleStartMinutes = ud.object(forKey: "dnd_schedule_start") as? Int ?? 22 * 60  // default 22:00
		scheduleEndMinutes   = ud.object(forKey: "dnd_schedule_end")   as? Int ?? 8  * 60  // default  8:00
	}

	// MARK: - Active check

	/// Returns true if DND should suppress incoming calls right now.
	var isCurrentlyActive: Bool {
		if isManuallyEnabled { return true }
		guard isScheduleEnabled else { return false }

		let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
		let nowMinutes = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)

		if scheduleStartMinutes <= scheduleEndMinutes {
			// Same-day range e.g. 09:00 – 17:00
			return nowMinutes >= scheduleStartMinutes && nowMinutes < scheduleEndMinutes
		} else {
			// Overnight range e.g. 22:00 – 08:00
			return nowMinutes >= scheduleStartMinutes || nowMinutes < scheduleEndMinutes
		}
	}

	// MARK: - Helpers

	static func minutesToDate(_ minutes: Int) -> Date {
		var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
		comps.hour   = minutes / 60
		comps.minute = minutes % 60
		comps.second = 0
		return Calendar.current.date(from: comps) ?? Date()
	}

	static func dateToMinutes(_ date: Date) -> Int {
		let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
		return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
	}
}
