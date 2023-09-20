//
//  Address.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/19/23.
//

import Foundation

struct Address: Encodable, Decodable {
	private var _title: String?
	private var _details: String
	private var _lat: Double
	private var _lng: Double

	var title: String? {
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

	init(title: String? = nil, details: String, lat: Double, lng: Double) {
		self._title = title
		self._details = details
		self._lat = lat
		self._lng = lng
	}
}

struct ReverseGeocodingAPIResponseType: Decodable {
	let status: String
	let formatted_address: String
//	let route_name: String?
//	let route_type: String
	let neighbourhood: String
//	let city: String
//	let state: String
//	let place: String?
//	let municipality_zone: String?
//	let in_traffic_zone: Bool
//	let in_odd_even_zone: Bool
//	let village: String?
//	let county: String?
//	let district: String
}
