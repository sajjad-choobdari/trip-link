//
//  TripsModel.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/16/23.
//

import Foundation

class Trips {
	private static var items: [Trip] = []

	func getItems() -> [Trip] {
		return Trips.items
	}

	static func syncLocalTripsWithDatabase() {
		do {
			Trips.items = try UserDefaultTripsStore.shared.fetchTrips()
		} catch {
			print("Error occurred while decoding data: \(error)")
		}
	}

	private func storeToUserDefaults() {
		do {
			try UserDefaultTripsStore.shared.storeTrips(Trips.items)
		} catch {
			print("Error occurred while storing trips: \(error)")
		}
	}

	func addNewTrip(
		title: String,
		description: String? = nil,
		origin: Address,
		destination: Address,
		completion: ((Trip) -> Void)? = nil
	) {
		let newTrip = Trip(title: title, description: description, origin: origin, destination: destination)
		Trips.items.append(newTrip)
		storeToUserDefaults()
		completion?(newTrip)
	}

	func deleteTrip(index: Int, completion: (() -> Void)? = nil) {
		if Trips.items.indices.contains(index) {
			Trips.items.remove(at: index)
			storeToUserDefaults()
			completion?()
		} else {
			print("Index does not exist in the array")
		}
	}

	func deleteTripByUUID(id: UUID, completion: (() -> Void)? = nil) {
		if let index = Trips.items.firstIndex(where: { $0.id == id }) {
			Trips.items.remove(at: index)
			storeToUserDefaults()
			completion?()
		} else {
			print("There is no trip with this id")
		}
	}
}
