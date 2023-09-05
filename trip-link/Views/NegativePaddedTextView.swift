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
