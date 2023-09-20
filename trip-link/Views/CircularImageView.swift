//
//  CircularImageView.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/1/23.
//

import Foundation
import UIKit


protocol Roundable {
	func resize(size: CGFloat)
	func makeRound()
}

extension Roundable where Self: UIImageView {
	func resize(size: CGFloat) {
		let newSize = CGSize(width: size, height: size)
		self.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
	}

	func makeRound() {
		self.contentMode = .scaleAspectFill
		self.clipsToBounds = true
		self.layer.cornerRadius = self.frame.size.width / 2
	}
}

extension UIImageView: Roundable {}

class CircularImageView: UIImageView {
	override func layoutSubviews() {
		super.layoutSubviews()
		self.makeRound()
	}
}
