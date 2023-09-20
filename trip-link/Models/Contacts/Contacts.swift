	//
	//  ContactsModel.swift
	//  trip-link
	//
	//  Created by Sajjad Choobdari on 8/28/23.
	//

import Foundation
import UIKit

class Contacts {
	private static var items: [Contact] = []

	static func syncLocalContactsWithDatabase() {
		do {
			Contacts.items = try UserDefaultContactsStore.shared.fetchContacts()
		} catch {
			print("Error occurred while decoding data: \(error)")
		}
	}

	private func storeContacts() {
		do {
			try UserDefaultContactsStore.shared.storeContacts(Contacts.items)
		} catch {
			print("Error occurred while storing contact: \(error)")
		}
	}

	func loadDeviceContacts(completion: (() -> Void)? = nil) {
		do {
			let deviceContacts = try CNContactDeviceContactsLoader.shared.loadDeviceContacts()
			Contacts.items.append(contentsOf: deviceContacts)
			storeContacts()
			completion?()
		} catch {
			print("Failed to load device contacts: \(error)")
		}
	}

	func getItems() -> [Contact] {
		return Contacts.items
	}

	func addNewContact(
		firstName: String? = nil,
		lastName: String? = nil,
		phone: String? = nil,
		email: String? = nil,
		note: String? = nil,
		image: Data? = nil,
		completion: ((Contact) -> Void)? = nil
	) {
		let newContact = Contact(
			firstName: firstName,
			lastName: lastName,
			phone: phone,
			email: email,
			note: note,
			image: image
		)
		Contacts.items.append(newContact)
		storeContacts()
		completion?(newContact)
	}

	func deleteContact(index: Int, completion: (() -> Void)? = nil) {
		if Contacts.items.indices.contains(index) {
			Contacts.items.remove(at: index)
			storeContacts()
			completion?()
		} else {
			print("Index does not exist in the array")
		}
	}

	func deleteContactByUUID(id: UUID, completion: (() -> Void)? = nil) {
		if let index = Contacts.items.firstIndex(where: { $0.immutableProps.id == id }) {
			Contacts.items.remove(at: index)
			storeContacts()
			completion?()
		} else {
			print("There is no contact with this id")
		}
	}

	func updateContactByUUID(id: UUID, modifiedData: MutableContactProperties, completion: (() -> Void)? = nil) {
		if let index = Contacts.items.firstIndex(where: { $0.immutableProps.id == id }) {
			Contacts.items[index].mutableProps = modifiedData
			storeContacts()
			completion?()
		} else {
			print("There is no contact with this id")
		}
	}

	func deleteAllContacts(completion: (() -> Void)? = nil) {
		Contacts.items = []
		storeContacts()
		completion?()
	}
}
