//
//  Helpers.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/1/23.
//

import Foundation
import UIKit

func instantiateViewController<T: UIViewController>(withIdentifier identifier: String, fromStoryboard named: String) -> T? {
	let storyboard = UIStoryboard(name: named, bundle: nil)
	return storyboard.instantiateViewController(withIdentifier: identifier) as? T
}
