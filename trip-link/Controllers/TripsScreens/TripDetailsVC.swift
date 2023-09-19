//
//  TripDetailsScreenVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/18/23.
//

import UIKit

class TripDetailsScreenVC: UIViewController {
	@IBOutlet private weak var descriptionInput: NegativePaddedTextView!
	@IBOutlet private weak var originAddressInput: NegativePaddedTextView!
	@IBOutlet private weak var destinationAddressInput: NegativePaddedTextView!
	@IBOutlet private weak var titleInput: UITextField!

	// Variables
	private var apiKey = "service.dacdc7fa09f24697a84c58665958dcd0"
	private lazy var networkManager = NetworkManager(apiKey: apiKey)
	weak var tripMapScreenDelegate: TripMapScreenDelegate?

	// Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

//		if let loc = NTLngLat(x: userLocation.coordinate.longitude, y: userLocation.coordinate.latitude) {
//			fetchAddressOf(
//				location: loc,
//				completion: { address in
//					print("address:", address)
//				}
//			)
//		}
	}


	// Methods
	private func fetchAddressOf(location: NTLngLat, completion: ((Address) -> Void)? = nil) {
		let requestURL: String = String(format: "https://api.neshan.org/v5/reverse?lat=%f&lng=%f", location.getY(), location.getX())
		let latLngAddr: String = String(format: "%.6f, %.6f", location.getY(), location.getX())

		let url: URL = URL(string: requestURL)!
		self.networkManager.fetchRequest(with: url, decodeType: ReverseGeocodingAPIResponseType.self) { (result: Result<ReverseGeocodingAPIResponseType?, APIError>) in
			switch result {
				case .success(let data):
					guard let address = data else {
						completion?(Address(title: "Unknown Address", details: latLngAddr, lat: location.getY(), lng: location.getX()))
						return
					}

					completion?(Address(title: address.neighbourhood, details: address.formatted_address, lat: location.getY(), lng: location.getX()))
					break

				case .failure(let error):
					print("Networking or Decoding error: \(error)")
					completion?(Address(title: "Unknown Address", details: latLngAddr, lat: location.getY(), lng: location.getX()))
					break
			}
		}
	}

	// Actions
	@IBAction private func onPressDone(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
		tripMapScreenDelegate?.didRequestBack()
	}

	@IBAction private func onPressCancel(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}
