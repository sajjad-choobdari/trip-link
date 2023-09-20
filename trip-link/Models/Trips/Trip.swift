//
//  Trip.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/19/23.
//

import Foundation

struct Trip: Encodable, Decodable {
	let id: UUID
	let createdAt: Date
	var title: String
	var description: String?
	var origin: Address
	var destination: Address

	init(title: String, description: String? = nil, origin: Address, destination: Address) {
		self.id = UUID.init()
		self.createdAt = Date()
		self.title = title
		self.description = description
		self.origin = origin
		self.destination = destination
	}
}
