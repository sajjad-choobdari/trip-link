//
//  ContactsModel.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/28/23.
//

import Foundation
import UIKit

struct ImmutableContactProperties {
	let id: UUID
	let createdAt: Date
	init() {
		self.id = UUID.init()
		self.createdAt = Date()
	}
}

struct MutableContactProperties {
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

struct Contact {
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
	private static var items: [Contact] = []

	public func getItems() -> [Contact] {
		return Contacts.items
	}

	public func addNewContact(
		firstName: String? = nil,
		lastName: String? = nil,
		phone: String? = nil,
		email: String? = nil,
		note: String? = nil,
		birthday: Date? = nil,
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
		onSuccess(newContact)
	}

	public func deleteContact(index: Int) {
		if (Contacts.items.indices.contains(index)) {
			Contacts.items.remove(at: index)
		} else {
			print("Index does not exist in the array")
			return
		}
	}
	public func deleteContactByUUID(id: UUID) {
		if let index = Contacts.items.firstIndex(where: { $0.immutableProps.id == id }) {
			Contacts.items.remove(at: index)
		} else {
			print("there is no contact with this id")
			return
		}
	}

	public func updateContactByUUID(id: UUID, modifiedData: MutableContactProperties, onSuccess: () -> Void) {
		if let index = Contacts.items.firstIndex(where: { $0.immutableProps.id == id }) {
			Contacts.items[index].mutableProps = modifiedData
			onSuccess()
		} else {
			print("there is no contact with this id")
			return
		}
	}

}
