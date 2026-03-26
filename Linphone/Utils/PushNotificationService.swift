/*
 * PushNotificationService.swift
 *
 * Registers the device's VoIP token with our push notification server.
 * Endpoint: POST <serverBaseUrl>/api/notifications/register
 */

import Foundation
import linphonesw

class PushNotificationService {

	static let serverBaseUrl = "https://sp.22792.me:8087"

	// Cached VoIP token — set as soon as PKPushRegistry delivers it.
	private(set) static var currentVoipToken: String?
	private(set) static var currentDeviceToken: String = ""

	/// Call whenever a new VoIP token arrives from PKPushRegistry.
	/// If a user is already logged in the token is registered immediately.
    static func updateVoipToken(_ token: String, address: Address?) {
		Log.info("[PushNotificationService] VoIP token updated: \(token)")
		currentVoipToken = token
        if let username = address?.username, !username.isEmpty {
            let domain = address?.domain
            registerDevice(username: username, voipToken: token, deviceToken: currentDeviceToken, domain: domain)
		}
	}

    static func updateDeviceToken(_ token: String, address: Address?) {
		Log.info("[PushNotificationService] Device token updated: \(token)")
		if(currentDeviceToken != token) {
			currentDeviceToken = token
            if let address = address {
                registerIfTokenAvailable(address: address)
			}
		}
	}

	/// Call after a successful SIP registration so the server knows about this device.
    static func registerIfTokenAvailable(address: Address) {
		guard let token = currentVoipToken else {
			Log.warn("[PushNotificationService] registerIfTokenAvailable: no VoIP token yet, skipping")
			return
		}
        if let username = address.username {
            let domain = address.domain
            registerDevice(username: username, voipToken: token, deviceToken: currentDeviceToken, domain: domain)
        }
	}

	/// Call when the user logs out so the server stops delivering pushes to this device.
    static func unregisterDevice(address: Address?) {
		guard let token = currentVoipToken else {
			Log.warn("[PushNotificationService] unregisterDevice: no VoIP token cached, skipping")
			return
		}

		guard let url = URL(string: "\(serverBaseUrl)/api/notifications/unregister") else {
			Log.error("[PushNotificationService] Invalid server URL for unregister")
			return
		}

#if DEBUG
    let pushEnvironment = "development"
#else
    let pushEnvironment = "production"
#endif
        let username = address?.username ?? ""
        let domain = address?.domain
		let body: [String: String] = [
			"username": username,
            "domain": domain ?? "hcloud.inticube.com",
			"deviceToken": currentDeviceToken,
			"voipToken": token,
			"platform": "ios",
			"environment": pushEnvironment
		]

		guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
			Log.error("[PushNotificationService] Failed to serialise unregister body")
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = httpBody

		Log.info("[PushNotificationService] Unregistering device for username=\(username)")

		URLSession.shared.dataTask(with: request) { _, response, error in
			if let error = error {
				Log.error("[PushNotificationService] Unregister failed: \(error.localizedDescription)")
				return
			}
			if let httpResponse = response as? HTTPURLResponse {
				if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
					Log.info("[PushNotificationService] Device unregistered successfully")
				} else {
					Log.error("[PushNotificationService] Unregister returned status \(httpResponse.statusCode)")
				}
			}
		}.resume()
	}

	// MARK: - Private

    static func registerDevice(username: String, voipToken: String, deviceToken: String, domain: String?) {
		guard let url = URL(string: "\(serverBaseUrl)/api/notifications/register") else {
			Log.error("[PushNotificationService] Invalid server URL")
			return
		}

		#if DEBUG
			let pushEnvironment = "development"
		#else
			let pushEnvironment = "production"
		#endif

		let body: [String: String] = [
			"username": username,
            "domain": domain ?? "hcloud.inticube.com",
			"deviceToken": deviceToken,
			"voipToken": voipToken,
			"platform": "ios",
			"environment": pushEnvironment
		]
        
        Log.info("register voip token for \(username) - \(String(describing: domain))")

		guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
			Log.error("[PushNotificationService] Failed to serialise request body")
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = httpBody

		Log.info("[PushNotificationService] Registering device for username=\(username)")

		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				Log.error("[PushNotificationService] Register failed: \(error.localizedDescription)")
				return
			}
			if let httpResponse = response as? HTTPURLResponse {
				if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
					Log.info("[PushNotificationService] Device registered successfully")
				} else {
					Log.error("[PushNotificationService] Server returned status \(httpResponse.statusCode)")
				}
			}
            Log.info("[PushNotificationService] Registering device DONE")
		}.resume()
	}
}
