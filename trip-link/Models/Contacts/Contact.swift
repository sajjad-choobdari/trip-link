//
//  Contact.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/19/23.
//

import Foundation

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
