//
//  ContactsModel.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/28/23.
//

import Foundation
import UIKit

struct Contact {
	var id: UUID
	var createdAt: Date
	var givenName: String?
	var familyName: String?
	var phoneNumber: String?
	var emailAddress: String?
	var note: String?
	var birthday: Date?
	var image: Data?

	init(
		firstName: String? = nil,
		lastName: String? = nil,
		phone: String? = nil,
		email: String? = nil,
		note: String? = nil,
		birthday: Date? = nil,
		image: Data? = nil
	) {
		self.id = UUID.init()
		self.createdAt = Date()

		self.givenName = firstName
		self.familyName = lastName
		self.birthday = birthday
		self.emailAddress = email
		self.phoneNumber = phone

		if let imageData = image {
			self.image = imageData
		}
	}
}

class Contacts {
	private var items: [Contact] = []

	public func getItems() -> [Contact] {
		return self.items
	}

	public func addNewContact(
		firstName: String? = nil,
		lastName: String? = nil,
		phone: String? = nil,
		email: String? = nil,
		note: String? = nil,
		birthday: Date? = nil,
		image: Data? = nil
	) {
		let newContact = Contact(
			firstName: firstName,
			lastName: lastName,
			phone: phone,
			email: email,
			note: note,
			birthday: birthday,
			image: image
		)
		self.items.append(newContact)
	}

	public func deleteContact(index: Int) {
		if (self.items.indices.contains(index)) {
			self.items.remove(at: index)
		} else {
			print("Index does not exist in the array")
			return
		}
	}

}
