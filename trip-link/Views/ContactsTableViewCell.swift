//
//  ContactsTableViewCell.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/3/23.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		if let imageView = self.imageView {
			self.makeImageViewCircular(imageView)
		}
	}

	private func makeImageViewCircular(_ imageView: UIImageView) {
		imageView.makeCircular(size: 40.0)
	}
}

extension UIImageView {
	func makeCircular(size: CGFloat) {
		let imageSize = CGSize(width: size, height: size)
		self.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
		self.contentMode = .scaleAspectFill
		self.clipsToBounds = true
		self.layer.cornerRadius = self.frame.size.height / 2
	}
}
