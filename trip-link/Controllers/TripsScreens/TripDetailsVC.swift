//
//  TripDetailsScreenVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/18/23.
//

import UIKit

typealias PathData = (
	origin: NTLngLat,
	destination: NTLngLat
)

protocol TripMapScreenVCDelegate: AnyObject {
	func passData(_ data: PathData)
}

class TripDetailsScreenVC: UIViewController {
	@IBOutlet private weak var descriptionInput: NegativePaddedTextView!
	@IBOutlet private weak var originAddressInput: NegativePaddedTextView!
	@IBOutlet private weak var destinationAddressInput: NegativePaddedTextView!
	@IBOutlet weak var originAddressLoadingIndicator: UIActivityIndicatorView!
	@IBOutlet weak var destinationAddressLoadingIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var titleInput: UITextField!

	@IBOutlet weak var doneButton: UIBarButtonItem!

		// Variables
	private var apiKey = "service.dacdc7fa09f24697a84c58665958dcd0"
	private lazy var networkManager = NetworkManager(apiKey: apiKey)
	weak var tripMapScreenDelegate: TripMapScreenDelegate?
	private var data: PathData?
	private let tripsModel = Trips()

	// Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		titleInput.becomeFirstResponder()
		doneButton.isEnabled = false

		guard let data = self.data else {
			return
		}

		originAddressLoadingIndicator.startAnimating()
		fetchAddressOf(
			location: data.origin,
			completion: { originAddress in
				self.originAddressInput.text = originAddress.details
				self.originAddressLoadingIndicator.stopAnimating()
				if (!self.destinationAddressLoadingIndicator.isAnimating) {
					self.doneButton.isEnabled = true
				}
			}
		)

		destinationAddressLoadingIndicator.startAnimating()
		fetchAddressOf(
			location: data.destination,
			completion: { destinationAddress in
				self.destinationAddressInput.text = destinationAddress.details
				self.destinationAddressLoadingIndicator.stopAnimating()
				if (!self.originAddressLoadingIndicator.isAnimating) {
					self.doneButton.isEnabled = true
				}
			}
		)
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
		guard let data = self.data else {
			return
		}
		let origin = Address(
			details: originAddressInput.text,
			lat: data.origin.getY(),
			lng: data.origin.getX()
		)
		let destination = Address(
			details: destinationAddressInput.text,
			lat: data.destination.getY(),
			lng: data.destination.getX()
		)
		tripsModel.addNewTrip(
			title: titleInput.text ?? "",
			description: descriptionInput.text ?? "",
			origin: origin,
			destination: destination
		)
		self.dismiss(animated: true, completion: nil)
		tripMapScreenDelegate?.didRequestBack()
	}

	@IBAction private func onPressCancel(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension TripDetailsScreenVC: TripMapScreenVCDelegate {
	func passData(_ data: PathData) {
		self.data = data
	}
}
