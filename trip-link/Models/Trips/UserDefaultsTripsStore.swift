//
//  UserDefaultsTripsStore.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/19/23.
//

import Foundation

protocol TripsStore {
	func fetchTrips() throws -> [Trip]
	func storeTrips(_ trips: [Trip]) throws
}

class UserDefaultTripsStore: TripsStore {
	private let tripsKey = "Trips"
	static let shared = UserDefaultTripsStore() // Singleton instance

	func fetchTrips() throws -> [Trip] {
		guard let encodedData = UserDefaults.standard.data(forKey: tripsKey) else {
			return []
		}
		let decoder = JSONDecoder()
		return try decoder.decode([Trip].self, from: encodedData)
	}

	func storeTrips(_ trips: [Trip]) throws {
		let encoder = JSONEncoder()
		let encodedData = try encoder.encode(trips)
		UserDefaults.standard.set(encodedData, forKey: tripsKey)
	}
}
