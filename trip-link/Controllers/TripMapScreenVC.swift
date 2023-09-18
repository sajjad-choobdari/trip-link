//
//  TripMapScreenVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/17/23.
//

import UIKit
import CoreLocation


protocol TripMapScreenDelegate: AnyObject {
	func didRequestBack()
}

class TripMapScreenVC: UIViewController, TripMapScreenDelegate {
	// Outlets
	@IBOutlet weak var mapContainer: UIView!
	@IBOutlet weak var currentLocationIndicatorView: UIView!

		// Variables
	private var apiKey = "service.dacdc7fa09f24697a84c58665958dcd0"
	lazy var networkManager = NetworkManager(apiKey: apiKey)
	var mapView: NTMapView?
	var destinationMarkerLayer: NTVectorElementLayer?
	var currentLocationMarkerLayer: NTVectorElementLayer?

	private let BASE_MAP_LAYER_INDEX: Int32 = 0
	private let UPDATE_INTERVAL_IN_MILISECONDS = 1000
	private let FASTEST_UPDATE_INTERVAL_IN_MILISECONDS = 1000

	var userLocation: CLLocation!
	var locationManager: CLLocationManager!

	let lastUpdateTime = NSString()
	let mRequestingLocationUpdates = Bool()

	func didRequestBack() {
		print("test")
		self.navigationController?.popViewController(animated: true)
	}

	// Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
			// Do any additional setup after loading the view.

		guard let map = initMap() else {
			return
		}
		setupMapEvents(on: map)

		mapContainer.addSubview(map)
		map.frame = mapContainer.bounds
		map.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		initLocation()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		startLocationUpdates()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidAppear(animated)
		stopLocationUpdates()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard let map = self.mapView else {
			return
		}
		let mapStyle = self.traitCollection.userInterfaceStyle == .dark ? NTNeshanMapStyle.STANDARD_NIGHT : NTNeshanMapStyle.NESHAN
		let baseMap = NTNeshanServices.createBaseMap(mapStyle)
		map.getLayers().set(BASE_MAP_LAYER_INDEX, layer: baseMap)
	}

	@IBAction func getCurrentLocationPressed(_ sender: UIButton) {
		focusOnCurrentLocation()
	}
	@IBAction func zoomInPressed(_ sender: UIButton) {
		zoomIn()
	}

	@IBAction func zoomOutPressed(_ sender: UIButton) {
		zoomOut()
	}

	// Methods
	func zoomIn() {
		guard let map = self.mapView else {
			return
		}
		map.setZoom(map.getZoom() + 1.0, durationSeconds: 0.5)
	}
	func zoomOut() {
		guard let map = self.mapView else {
			return
		}
		map.setZoom(map.getZoom() - 1.0, durationSeconds: 0.5)
	}

	func initLocation() {
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
	}

	func startLocationUpdates() {
		locationManager.startUpdatingLocation()
	}

	func stopLocationUpdates() {
		locationManager.stopUpdatingLocation()
	}


	func focusOnLocation(pos: NTLngLat, map: NTMapView) {
		map.setFocalPointPosition(pos, durationSeconds: 0.5)
		map.setZoom(15, durationSeconds: 0.5)
	}

	func focusOnCurrentLocation() {
		guard let map = self.mapView else {
			return
		}
		guard let userLocation = self.userLocation else {
			return
		}
		guard let pos = NTLngLat(x: userLocation.coordinate.longitude, y: userLocation.coordinate.latitude) else {
			return
		}
		focusOnLocation(pos: pos, map: map)
	}

	func updateCurrentLocationMarker() {
		guard let userLocation = self.userLocation else {
			return
		}
		guard let pos = NTLngLat(x: userLocation.coordinate.longitude, y: userLocation.coordinate.latitude) else {
			return
		}
		addCurrentLocationMarker(at: pos)
	}

	func createImage(from view: UIView, completion: @escaping (UIImage?) -> ()) {
		DispatchQueue.main.async {
			UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
			if let context = UIGraphicsGetCurrentContext() {
				view.layer.render(in: context)
				let image = UIGraphicsGetImageFromCurrentImageContext()
				UIGraphicsEndImageContext()
				completion(image)
			}
		}
	}


	func addCurrentLocationMarker(at position: NTLngLat) {
		createImage(from: currentLocationIndicatorView) { image in
			guard let markerImage = image else {
					return
			}
			let markerBitmap = NTBitmapUtils.createBitmap(from: markerImage)
			let markerStyleCreator = NTMarkerStyleCreator()
			let animationStyle = NTAnimationStyle()
			guard let markerStCr = markerStyleCreator else {
				return
			}
			markerStCr.setBitmap(markerBitmap)
			markerStCr.setSize(20)
			markerStCr.setAnimationStyle(animationStyle)
			let markerStyle = markerStCr.buildStyle()

			let marker = NTMarker(pos: position, style: markerStyle)

			guard let markerLayer = self.currentLocationMarkerLayer else {
				return
			}
			markerLayer.clear()
			markerLayer.add(marker)
		}
	}

	func setupMarkerAndAddToMap(at position: NTLngLat, on layer: NTVectorElementLayer?) {
		let markerImage = NTBitmapUtils.createBitmap(from: UIImage(systemName: "mappin"))
		let markerStyleCreator = NTMarkerStyleCreator()
		let animationStyle = NTAnimationStyle()
		guard let markerStCr = markerStyleCreator else {
			return
		}
		
		markerStCr.setBitmap(markerImage)
		markerStCr.setSize(20)
		markerStCr.setAnimationStyle(animationStyle)
		let markerStyle = markerStCr.buildStyle()

		let marker = NTMarker(pos: position, style: markerStyle)

		guard let markerLayer = layer else {
			return
		}
		markerLayer.clear()
		markerLayer.add(marker)
		guard let vectorElementEventListener = VectorElementClickedListener() else {
			return
		}
		vectorElementEventListener.onVectorElementClickedBlock = { clickInfo in
			if clickInfo.getClickType() == NTClickType.CLICK_TYPE_SINGLE {
				markerLayer.remove(clickInfo.getVectorElement())
			}
			return true
		}
		markerLayer.setVectorElementEventListener(vectorElementEventListener)
	}

	func initMap() -> NTMapView? {
		mapView = NTMapView()
		guard let map = self.mapView else {
			return nil
		}

		let mapStyle = self.traitCollection.userInterfaceStyle == .dark ? NTNeshanMapStyle.STANDARD_NIGHT : NTNeshanMapStyle.NESHAN
		let baseMap = NTNeshanServices.createBaseMap(mapStyle)
		map.getLayers().insert(BASE_MAP_LAYER_INDEX, layer: baseMap)

		self.destinationMarkerLayer = NTNeshanServices.createVectorElementLayer()
		if let destMarkerLayer = self.destinationMarkerLayer {
			map.getLayers().add(destMarkerLayer)
		}

		self.currentLocationMarkerLayer = NTNeshanServices.createVectorElementLayer()
		if let curLocMarkerLayer = self.currentLocationMarkerLayer {
			map.getLayers().add(curLocMarkerLayer)
		}

		let initialFocalPoint = NTLngLat(x:59.6,y:36.3)
		map.setFocalPointPosition(initialFocalPoint, durationSeconds: 0.5)
		map.getOptions().setZoom(NTRange(min: 4.5, max: 18))
		map.setZoom(12, durationSeconds: 0.5)

		map.getLayers().add(destinationMarkerLayer)

		return map
	}

	func setupMapEvents(on map: NTMapView) {

		guard let mapEventListener = MapEventListener() else {
			return
		}

		mapEventListener.onMapClickedBlock =  { clickInfo in
			if clickInfo.getClickType() == NTClickType.CLICK_TYPE_SINGLE {
//				if let clickedLocation = clickInfo.getClickPos() {
//					self.setupMarkerAndAddToMap(at: clickedLocation, on: self.destinationMarkerLayer)
//				}

			} else if clickInfo.getClickType() == NTClickType.CLICK_TYPE_DOUBLE {
				self.zoomIn()
			} else if clickInfo.getClickType() == NTClickType.CLICK_TYPE_LONG {
				self.zoomOut()
			}
		}

		map.setMapEventListener(mapEventListener)
	}

	// Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EditTripDetailsSegue" {
			guard let destinationNC = segue.destination as? UINavigationController else {
				return
			}

			guard let destinationVC = destinationNC.viewControllers.first as? TripDetailsScreenVC else {
				return
			}
			print(type(of: destinationVC.tripMapScreenDelegate))
			destinationVC.tripMapScreenDelegate = self
		}
	}

}


extension TripMapScreenVC: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		AlertUtility.showAlert(on: self, title: "Couldn't get current location", primaryActionTitle: "OK")
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		var justGotInitialized = false
		if userLocation == nil {
			justGotInitialized = true
		}
		userLocation = locations.last
		updateCurrentLocationMarker()
		if (justGotInitialized) {
			focusOnCurrentLocation()
		}
	}
}
