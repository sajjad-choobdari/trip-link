//
//  UserDefaultsContactsStore.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/19/23.
//

import Foundation

protocol ContactStore {
	func fetchContacts() throws -> [Contact]
	func storeContacts(_ contacts: [Contact]) throws
}

class UserDefaultContactsStore: ContactStore {
	private let contactsKey = "Contacts"
	static let shared = UserDefaultContactsStore() // Singleton instance

	private init() {}

	func fetchContacts() throws -> [Contact] {
		guard let encodedData = UserDefaults.standard.data(forKey: contactsKey) else {
			return []
		}
		let decoder = JSONDecoder()
		return try decoder.decode([Contact].self, from: encodedData)
	}

	func storeContacts(_ contacts: [Contact]) throws {
		let encoder = JSONEncoder()
		let encodedData = try encoder.encode(contacts)
		UserDefaults.standard.set(encodedData, forKey: contactsKey)
	}
}
