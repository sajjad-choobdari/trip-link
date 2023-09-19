//
//  TripsModel.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/16/23.
//

import Foundation

struct Trip: Encodable, Decodable {
	let id: UUID
	let createdAt: Date
	var title: String

	init(title: String) {
		self.id = UUID.init()
		self.createdAt = Date()
		self.title = title
	}
}

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

class Trips {
	private static var items: [Trip] = [Trip(title: "Test")]

	static func syncLocalTripsWithDatabase() {
		do {
			Trips.items = try UserDefaultTripsStore.shared.fetchTrips()
		} catch {
			print("Error occurred while decoding data: \(error)")
		}
	}

	func getItems() -> [Trip] {
		return Trips.items
	}

	func addNewTrip(
		title: String,
		completion: ((Trip) -> Void)? = nil
	) {
		let newTrip = Trip(title: title)
		Trips.items.append(newTrip)
		do {
			try UserDefaultTripsStore.shared.storeTrips(Trips.items)
			completion?(newTrip)
		} catch {
			print("Error occurred while storing trips: \(error)")
		}
	}

	func deleteTrip(index: Int) {
		if Trips.items.indices.contains(index) {
			Trips.items.remove(at: index)
			do {
				try UserDefaultTripsStore.shared.storeTrips(Trips.items)
			} catch {
				print("Error occurred while storing trips after deletion: \(error)")
			}
		} else {
			print("Index does not exist in the array")
		}
	}

	func deleteTripByUUID(id: UUID) {
		if let index = Trips.items.firstIndex(where: { $0.id == id }) {
			Trips.items.remove(at: index)
			do {
				try UserDefaultTripsStore.shared.storeTrips(Trips.items)
			} catch {
				print("Error occurred while storing trips after deletion: \(error)")
			}
		} else {
			print("There is no trip with this id")
		}
	}
}


struct ReverseGeocodingAPIResponseType: Decodable {
	let status: String
	let formatted_address: String
	let route_name: String?
	let route_type: String
	let neighbourhood: String
	let city: String
	let state: String
	let place: String?
	let municipality_zone: String?
	let in_traffic_zone: Bool
	let in_odd_even_zone: Bool
	let village: String?
	let county: String?
	let district: String
}

struct Address {
	private var _title: String
	private var _details: String
	private var _lat: Double
	private var _lng: Double

	var title: String {
		get { return _title }
		set(newTitle) { _title = newTitle }
	}
	var details: String {
		get { return _details }
		set(newDetails) { _details = newDetails }
	}
	var lat: Double {
		get { return _lat }
		set(newLat) { _lat = newLat }
	}
	var lng: Double {
		get { return _lng }
		set(newLng) { _lng = newLng }
	}

	init(title: String, details: String, lat: Double, lng: Double) {
		self._title = title
		self._details = details
		self._lat = lat
		self._lng = lng
	}
}
