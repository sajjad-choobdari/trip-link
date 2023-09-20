//
//  AlertUtility.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/5/23.
//

import Foundation
import UIKit

struct AlertUtility {
	private init() {}

	static func showActionSheet(
		on viewController: UIViewController,
		title: String, message: String,
		confirmActionTitle: String? = "Confirm", confirmActionStyle: UIAlertAction.Style? = .default, confirmHandler: ((UIAlertAction) -> Void)? = nil,
		cancelActionTitle: String? = "Cancel", cancelActionStyle: UIAlertAction.Style? = .cancel, cancelHandler: ((UIAlertAction) -> Void)? = nil
	) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: confirmActionTitle ?? "Confirm", style: confirmActionStyle ?? .default, handler: confirmHandler ?? nil))
		alert.addAction(UIAlertAction(title: cancelActionTitle ?? "Cancel", style: cancelActionStyle ?? .cancel, handler: cancelHandler ?? nil))
		viewController.present(alert, animated: true, completion: nil)
	}

	static func showAlert(
		on viewController: UIViewController,
		title: String, message: String? = "",
		primaryActionTitle: String, primaryActionHandler: ((UIAlertAction) -> Void)? = nil
	) {
		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: primaryActionTitle, style: .default, handler: primaryActionHandler))
		viewController.present(alert, animated: true, completion: nil)
	}
}
