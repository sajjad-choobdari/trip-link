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
//	var birthday: Date?

	init(
		firstName: String? = nil,
		lastName: String? = nil,
		phone: String? = nil,
		email: String? = nil,
		note: String? = nil,
		image: Data? = nil
//		birthday: Date? = nil,
	) {

		self.givenName = firstName
		self.familyName = lastName
		self.emailAddress = email
		self.phoneNumber = phone
		self.note = note
//		self.birthday = birthday

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

class Contacts {
	private let contactsKey = "Contacts"
	private static var items: [Contact] = []
//	private let userDefaults = UserDefaults.standard

	func getItems() -> [Contact] {
		return Contacts.items
	}

	func loadDeviceContacts(onDone: (() -> Void)? = nil) {
		do {
			let deviceContactsStore = CNContactStore()
			let keysToFetch = [
				CNContactGivenNameKey,
				CNContactFamilyNameKey,
				CNContactPhoneNumbersKey,
				CNContactEmailAddressesKey,
				CNContactImageDataKey
			]
			/*
			 As of Oct 2020 due to privacy concern, Apple adds a restriction on reading the notes field of a contact.
			 Your app needs to be specifically entitled by Apple to access this field.
			 Access to contacts' notes is only granted in a very limited set of circumstances.
			*/
			let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])

			if (hasContactsAccess()) {
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
					Contacts.items.append(newContact)
				}
				writeLocalContactsToDatabase()
				onDone?()
			}
		}  catch {
			print("Failed to load device contacts, error: \(error)")
		}

	}
	private func fetchContactsFromDatabase() -> [Contact] {
		guard let encodedData = UserDefaults.standard.data(forKey: contactsKey) else {
			return []
		}
		do {
			let decoder = JSONDecoder()
			let savedContacts = try decoder.decode([Contact].self, from: encodedData)
			return savedContacts
		} catch {
			print("Error occurred while decoding data: \(error)")
			return []
		}
	}
	private func writeLocalContactsToDatabase() {
		do {
			let encoder = JSONEncoder()
			let encodedData = try encoder.encode(Contacts.items)
			UserDefaults.standard.set(encodedData, forKey: contactsKey)
		} catch {
			print("Error occurred while encoding data: \(error)")
		}
	}

	func syncLocalContactsWithDatabase() {
		Contacts.items = fetchContactsFromDatabase()
	}

	func addNewContact(
		firstName: String? = nil,
		lastName: String? = nil,
		phone: String? = nil,
		email: String? = nil,
		note: String? = nil,
//		birthday: Date? = nil,
		image: Data? = nil,
		onSuccess: (Contact) -> Void
	) {
		let newContact = Contact(
			firstName: firstName,
			lastName: lastName,
			phone: phone,
			email: email,
			note: note,
//			birthday: birthday,
			image: image
		)
		Contacts.items.append(newContact)
		writeLocalContactsToDatabase()
		onSuccess(newContact)
	}

	func deleteContact(index: Int) {
		if (Contacts.items.indices.contains(index)) {
			Contacts.items.remove(at: index)
			writeLocalContactsToDatabase()
		} else {
			print("Index does not exist in the array")
			return
		}
	}
	func deleteContactByUUID(id: UUID) {
		if let index = Contacts.items.firstIndex(where: { $0.immutableProps.id == id }) {
			Contacts.items.remove(at: index)
			writeLocalContactsToDatabase()
		} else {
			print("there is no contact with this id")
			return
		}
	}

	func updateContactByUUID(id: UUID, modifiedData: MutableContactProperties, onSuccess: () -> Void) {
		if let index = Contacts.items.firstIndex(where: { $0.immutableProps.id == id }) {
			Contacts.items[index].mutableProps = modifiedData
			writeLocalContactsToDatabase()
			onSuccess()
		} else {
			print("there is no contact with this id")
			return
		}
	}

	func deleteAllContacts(onDone: (() -> Void)? = nil) {
		Contacts.items = []
		writeLocalContactsToDatabase()
		onDone?()
	}

}
