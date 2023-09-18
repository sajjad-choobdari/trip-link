//
//  TripDetailsScreenVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/18/23.
//

import UIKit

class TripDetailsScreenVC: UIViewController {
	@IBOutlet weak var descriptionInput: NegativePaddedTextView!
	@IBOutlet weak var originAddressInput: NegativePaddedTextView!
	@IBOutlet weak var destinationAddressInput: NegativePaddedTextView!
	@IBOutlet weak var titleInput: UITextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	weak var tripMapScreenDelegate: TripMapScreenDelegate?

	@IBAction func onPressDone(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
		tripMapScreenDelegate?.didRequestBack()
	}

	@IBAction func onPressCancel(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}
