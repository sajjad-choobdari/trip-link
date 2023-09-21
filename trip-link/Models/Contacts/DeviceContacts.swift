//
//  DeviceContacts.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/19/23.
//

import Foundation
import Contacts

protocol DeviceContactsLoader {
	func loadDeviceContacts() throws -> [Contact]
}

class CNContactDeviceContactsLoader: DeviceContactsLoader {
	static let shared = CNContactDeviceContactsLoader() // Singleton instance

	private init() {}

	func loadDeviceContacts() throws -> [Contact] {
		guard PermissionsManager.hasContactsAccess() else {
			return []
		}

		var contacts: [Contact] = []

		let deviceContactsStore = CNContactStore()
		let keysToFetch = [
			CNContactGivenNameKey,
			CNContactFamilyNameKey,
			CNContactPhoneNumbersKey,
			CNContactEmailAddressesKey,
			CNContactImageDataKey
		]
		let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])

		try deviceContactsStore.enumerateContacts(with: request) { (deviceContact, stop) in
			let givenName = deviceContact.givenName
			let familyName = deviceContact.familyName
			let phoneNumber = deviceContact.phoneNumbers.first?.value.stringValue ?? ""
			let emailAddress = deviceContact.emailAddresses.first?.value ?? ""
			let imageData = deviceContact.imageData

			let newContact = Contact(
				firstName: givenName,
				lastName: familyName,
				phone: phoneNumber,
				email: emailAddress as String?,
				image: imageData
			)
			contacts.append(newContact)
		}

		return contacts
	}
}
