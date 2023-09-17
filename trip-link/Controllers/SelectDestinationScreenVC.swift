//
//  SelectDestinationScreenVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/17/23.
//

import UIKit

class SelectDestinationScreenVC: UIViewController {
	// Outlets
	@IBOutlet weak var map: NTMapView!

	// Variables
	var mapview: NTMapView?

	// Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

		mapview = NTMapView();
		let neshan = NTNeshanServices.createBaseMap(NTNeshanMapStyle.NESHAN)
		mapview?.getLayers().add(neshan)

		let neshan2 = NTNeshanServices.createTrafficLayer()
		mapview?.getLayers().add(neshan2)

		let neshan3 = NTNeshanServices.createPOILayer(false)
		mapview?.getLayers().add(neshan3)

		mapview?.setFocalPointPosition(NTLngLat(x:59.2,y:36.5), durationSeconds: 0.4)
		mapview?.setZoom(13, durationSeconds: 0.4)

		map=mapview
	}

}
