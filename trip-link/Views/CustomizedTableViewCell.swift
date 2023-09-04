//
//  CustomizedTableViewCell.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/3/23.
//

import UIKit

class CustomizedTableViewCell: UITableViewCell {

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		if let imageView = self.imageView {
			let imageSize = CGSize(width: 40.0, height: 40.0)
			imageView.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
			imageView.contentMode = .scaleAspectFill
			imageView.clipsToBounds = true
			imageView.layer.cornerRadius = imageView.frame.size.height / 2
		}
	}
}
