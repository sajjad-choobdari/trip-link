//
//  CircularImageView.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/1/23.
//

import Foundation
import UIKit

@IBDesignable
class CircularImageView: UIImageView {
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = self.frame.size.width / 2
		self.clipsToBounds = true
	}
}
