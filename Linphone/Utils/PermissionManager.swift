/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
 *
 * This file is part of Linphone
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
import Photos
import UserNotifications
import SwiftUI
import Network

class PermissionManager: ObservableObject {
	
	static let shared = PermissionManager()
	
	@Published var pushPermissionGranted = false
	@Published var photoLibraryPermissionGranted = false
	@Published var cameraPermissionGranted = false
	@Published var contactsPermissionGranted = false
	@Published var microphonePermissionGranted = false
	@Published var allPermissionsHaveBeenDisplayed = false
	
	private init() {}
	
	func getPermissions() {
		pushNotificationRequestPermission {
			let dispatchGroup = DispatchGroup()
			
			dispatchGroup.enter()
			self.microphoneRequestPermission()
			self.photoLibraryRequestPermission(group: dispatchGroup)
			
			dispatchGroup.notify(queue: .main) {
				// Now request local network authorization last
				self.requestLocalNetworkAuthorization()
			}
		}
	}
	
	func pushNotificationRequestPermission(completion: @escaping () -> Void) {
		let options: UNAuthorizationOptions = [.alert, .sound, .badge]
		UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
			if let error = error {
				Log.error("Unexpected error when asking for Push permission : \(error.localizedDescription)")
			}
			DispatchQueue.main.async {
				self.pushPermissionGranted = granted
			}
			completion()
		}
	}
	
	func microphoneRequestPermission() {
		AVAudioSession.sharedInstance().requestRecordPermission({ granted in
			DispatchQueue.main.async {
				self.microphonePermissionGranted = granted
			}
		})
	}
	
	func photoLibraryRequestPermission(group: DispatchGroup) {
		PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: {status in
			DispatchQueue.main.async {
				self.photoLibraryPermissionGranted = (status == .authorized || status == .limited || status == .restricted)
			}
            group.leave()
		})
	}
	
	func cameraRequestPermission(group: DispatchGroup) {
		AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
			DispatchQueue.main.async {
				self.cameraPermissionGranted = accessGranted
			}
//            group.leave()
		})
	}
	
	func requestLocalNetworkAuthorization() {
		// Use a general UDP broadcast endpoint to attempt triggering the authorization request
		let host = NWEndpoint.Host("255.255.255.255") // Broadcast on the local network
		let port = NWEndpoint.Port(12345) // Choose an arbitrary port
		
		let params = NWParameters.udp
		let connection = NWConnection(host: host, port: port, using: params)
		
		connection.stateUpdateHandler = { newState in
			switch newState {
			case .ready:
				print("Connection ready")
				connection.cancel() // Close the connection after establishing it
			case .failed(let error):
				print("Connection failed: \(error)")
				connection.cancel()
			default:
				break
			}
		}
		connection.start(queue: .main)
		DispatchQueue.main.async {
			self.allPermissionsHaveBeenDisplayed = true
		}
	}
	
	func havePermissionsAlreadyBeenRequested() {
		let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
		let micStatus = AVAudioSession.sharedInstance().recordPermission
		let photoStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
//		let contactsStatus = CNContactStore.authorizationStatus(for: .contacts)
        let contactsStatus: UNAuthorizationStatus = .authorized //disable native contact
		
		let notifGroup = DispatchGroup()
		var notifStatus: UNAuthorizationStatus = .notDetermined
		
		notifGroup.enter()
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			notifStatus = settings.authorizationStatus
			notifGroup.leave()
		}
		
		notifGroup.notify(queue: .main) {
			let allAlreadyRequested = cameraStatus != .notDetermined &&
									  micStatus != .undetermined &&
									  photoStatus != .notDetermined &&
									  contactsStatus != .notDetermined &&
									  notifStatus != .notDetermined
			
			if allAlreadyRequested {
				self.allPermissionsHaveBeenDisplayed = true
			}
		}
	}

}
