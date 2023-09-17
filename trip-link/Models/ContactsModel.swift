	//
	//  ContactsModel.swift
	//  trip-link
	//
	//  Created by Sajjad Choobdari on 8/28/23.
	//

import Foundation
import UIKit
import Contacts

struct ImmutableContactProperties: Encodable, Decodable {
	let id: UUID
	let createdAt: Date

	init() {
		self.id = UUID.init()
		self.createdAt = Date()
	}
}

struct MutableContactProperties: Encodable, Decodable {
	var givenName: String?
	var familyName: String?
	var phoneNumber: String?
	var emailAddress: String?
	var note: String?
	var image: Data?

	init(
		firstName: String? = nil,
		lastName: String? = nil,
		phone: String? = nil,
		email: String? = nil,
		note: String? = nil,
		image: Data? = nil
	) {

		self.givenName = firstName
		self.familyName = lastName
		self.emailAddress = email
		self.phoneNumber = phone
		self.note = note

		if let imageData = image {
			self.image = imageData
		}
	}
}

struct Contact: Encodable, Decodable {
	let immutableProps: ImmutableContactProperties
	var mutableProps: MutableContactProperties

	init(
		firstName: String? = nil,
		lastName: String? = nil,
		phone: String? = nil,
		email: String? = nil,
		note: String? = nil,
		//		birthday: Date? = nil,
		image: Data? = nil
	) {
		immutableProps = ImmutableContactProperties()
		mutableProps = MutableContactProperties(
			firstName: firstName,
			lastName: lastName,
			phone: phone,
			email: email,
			note: note,
			image: image
		)
	}
}

protocol ContactStore {
	func fetchContacts() throws -> [Contact]
	func storeContacts(_ contacts: [Contact]) throws
}

class UserDefaultContactStore: ContactStore {
	private let contactsKey = "Contacts"
	static let shared = UserDefaultContactStore() // Singleton instance

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

protocol DeviceContactsLoader {
	func loadDeviceContacts() throws -> [Contact]
}

class CNContactDeviceContactsLoader: DeviceContactsLoader {
	private let permissionsManager = PermissionsManager()
	static let shared = CNContactDeviceContactsLoader() // Singleton instance

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

class Contacts {
	private static var items: [Contact] = []

	static func syncLocalContactsWithDatabase() {
		do {
			Contacts.items = try UserDefaultContactStore.shared.fetchContacts()
		} catch {
			print("Error occurred while decoding data: \(error)")
		}
	}

	func loadDeviceContacts(onDone: (() -> Void)? = nil) {
		do {
			let deviceContacts = try CNContactDeviceContactsLoader.shared.loadDeviceContacts()
			Contacts.items.append(contentsOf: deviceContacts)
			try UserDefaultContactStore.shared.storeContacts(Contacts.items)
			onDone?()
		} catch {
			print("Failed to load device contacts or saving them to store: \(error)")
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
		onSuccess: (Contact) -> Void
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
		do {
			try UserDefaultContactStore.shared.storeContacts(Contacts.items)
			onSuccess(newContact)
		} catch {
			print("Error occurred while storing contact: \(error)")
		}
	}

	func deleteContact(index: Int) {
		if Contacts.items.indices.contains(index) {
			Contacts.items.remove(at: index)
			do {
				try UserDefaultContactStore.shared.storeContacts(Contacts.items)
			} catch {
				print("Error occurred while storing contacts after deletion: \(error)")
			}
		} else {
			print("Index does not exist in the array")
		}
	}

	func deleteContactByUUID(id: UUID) {
		if let index = Contacts.items.firstIndex(where: { $0.immutableProps.id == id }) {
			Contacts.items.remove(at: index)
			do {
				try UserDefaultContactStore.shared.storeContacts(Contacts.items)
			} catch {
				print("Error occurred while storing contacts after deletion: \(error)")
			}
		} else {
			print("There is no contact with this id")
		}
	}

	func updateContactByUUID(id: UUID, modifiedData: MutableContactProperties, onSuccess: () -> Void) {
		if let index = Contacts.items.firstIndex(where: { $0.immutableProps.id == id }) {
			Contacts.items[index].mutableProps = modifiedData
			do {
				try UserDefaultContactStore.shared.storeContacts(Contacts.items)
				onSuccess()
			} catch {
				print("Error occurred while storing updated contact: \(error)")
			}
		} else {
			print("There is no contact with this id")
		}
	}

	func deleteAllContacts(onDone: (() -> Void)? = nil) {
		Contacts.items = []
		do {
			try UserDefaultContactStore.shared.storeContacts(Contacts.items)
			onDone?()
		} catch {
			print("Error occurred while storing contacts after deletion: \(error)")
		}
	}
}
