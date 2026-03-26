/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

import Foundation
import linphonesw

class CallForwardManager: ObservableObject {
	static let shared = CallForwardManager()

	private let enabledKey = "call_forward_enabled"
	private let numberKey = "call_forward_number"

	/// Whether call forwarding is currently enabled
	@Published var isEnabled: Bool {
        didSet {
            let current = UserDefaults.standard.bool(forKey: enabledKey)
            if current && !isEnabled {
                deactive()
            } else if isEnabled && !forwardNumber.isEmpty{
                activate()
            }
            UserDefaults.standard.set(isEnabled, forKey: enabledKey)
        }
	}

	/// The phone number to forward to (digits only, *77 prefix is added automatically)
	@Published var forwardNumber: String {
		didSet { UserDefaults.standard.set(forwardNumber, forKey: numberKey) }
	}

	/// Full address sent as req.URI: *77<forwardNumber>
	var fullForwardAddress: String { "\(forwardNumber)" }

	private init() {
		isEnabled = UserDefaults.standard.bool(forKey: enabledKey)
		forwardNumber = UserDefaults.standard.string(forKey: numberKey) ?? ""
	}

	/// Sends INVITE with req.URI = *77<forwardNumber> to activate call forwarding on the PBX.
	func activate() {
		guard !forwardNumber.isEmpty else { return }
		let target = "*77\(forwardNumber)"
		CoreContext.shared.performActionOnCoreQueueWhenCoreIsStarted { core in
            let address = try? Factory.Instance.createAddress(addr: target)
            if let address = address ?? core.interpretUrl(
				url: target,
				applyInternationalPrefix: false
			) {
				Log.info("[CallForwardManager] activating call forward — sending INVITE to \(target)")
                if let call = core.inviteAddress(addr: address) {
                    if let callLog = call.callLog {
                        core.removeCallLog(callLog: callLog)
                    }
                    try? call.terminate()
                    Log.info("[CallForwardManager] call state \(String(describing: call.state.rawValue))")
                }
			} else {
				Log.error("[CallForwardManager] unable to interpret call forward address: \(target)")
				DispatchQueue.main.async {
					ToastViewModel.shared.toastMessage = "call_forward_save_failed"
					ToastViewModel.shared.displayToast = true
				}
			}
		}
	}
    
    func deactive() {
        let target = "*78\(forwardNumber)"
        CoreContext.shared.performActionOnCoreQueueWhenCoreIsStarted { core in
            let address = try? Factory.Instance.createAddress(addr: target)
            if let address = address ?? core.interpretUrl(
                url: target,
                applyInternationalPrefix: false
            ) {
                Log.info("[CallForwardManager] deactivating call forward — sending INVITE to \(target)")
                if let call = core.inviteAddress(addr: address) {
                    if let callLog = call.callLog {
                        core.removeCallLog(callLog: callLog)
                    }
                    try? call.terminate()
                    Log.info("[CallForwardManager] call state \(String(describing: call.state.rawValue))")
                }
            } else {
                Log.error("[CallForwardManager] unable to interpret call forward address: \(target)")
                DispatchQueue.main.async {
                    ToastViewModel.shared.toastMessage = "call_forward_save_failed"
                    ToastViewModel.shared.displayToast = true
                }
            }
        }
    }
}
