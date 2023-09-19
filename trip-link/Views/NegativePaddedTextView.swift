//
//  NegativePaddedTextView.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/5/23.
//

import Foundation
import UIKit

class NegativePaddedTextView: UITextView {
	override func layoutSubviews() {
		super.layoutSubviews()
		textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -4)
	}
}

protocol PaddedTextView {
	var padding: UIEdgeInsets { get }
}

extension PaddedTextView where Self: UITextView {
	func applyPadding() {
		self.textContainerInset = self.padding
	}
}


@IBDesignable
class TextViewWithCustomPadding: UITextView, PaddedTextView {
	@IBInspectable var topPadding: CGFloat = 0.0
	@IBInspectable var leftPadding: CGFloat = -4.0
	@IBInspectable var bottomPadding: CGFloat = 0.0
	@IBInspectable var rightPadding: CGFloat = -4.0

	var padding: UIEdgeInsets {
		return UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.applyPadding()
	}
}
