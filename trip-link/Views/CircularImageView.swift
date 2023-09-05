//
//  CircularImageView.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/1/23.
//

import Foundation
import UIKit


protocol Roundable {
	func makeRound()
}

extension Roundable where Self: UIImageView {
	func makeRound() {
		self.layer.cornerRadius = self.frame.size.width / 2
		self.clipsToBounds = true
	}
}

class CircularImageView: UIImageView, Roundable {
	override func layoutSubviews() {
		super.layoutSubviews()
		makeRound()
	}
}
