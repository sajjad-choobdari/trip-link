//
//  ViewController.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/28/23.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet var contactsTableContainerView: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.embedChildVCIntoContainerView(ContactsTableVC.self, into: contactsTableContainerView)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.removeEmbeddedChildViewController(from: contactsTableContainerView)
	}

}
