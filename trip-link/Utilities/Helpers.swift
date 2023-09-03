//
//  Helpers.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/1/23.
//

import Foundation
import UIKit
import Contacts

func instantiateViewController<T: UIViewController>(withIdentifier identifier: String, fromStoryboard named: String) -> T? {
	let storyboard = UIStoryboard(name: named, bundle: nil)
	return storyboard.instantiateViewController(withIdentifier: identifier) as? T
}

func hasContactsAccess() -> Bool {
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

func requestContactsAccess(onGrantAccess: (() -> Void)? = nil) {
	let store = CNContactStore()
	if hasContactsAccess() == false {
		store.requestAccess(for: .contacts) { granted, error in
			if granted {
				onGrantAccess?()
			}
		}
	}
}
