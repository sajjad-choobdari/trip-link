//
//  PermissionManager.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/5/23.
//

import Foundation
import Contacts

class PermissionsManager {
	init() {
		//
	}

	static func hasContactsAccess() -> Bool {
		let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
		switch authorizationStatus {
			case .authorized:
				return true
			case .denied, .notDetermined, .restricted:
				return false
			@unknown default:
				return false
		}
	}

	static func requestContactsAccess(onGrantAccess: (() -> Void)? = nil) {
		let store = CNContactStore()
		if hasContactsAccess() == false {
			store.requestAccess(for: .contacts) { granted, error in
				if granted {
					onGrantAccess?()
				}
			}
		}
	}
}
