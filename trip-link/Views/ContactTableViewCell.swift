//
//  ContactTableViewCell.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/3/23.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

	@IBOutlet weak var contactImageView: UIImageView!
	@IBOutlet weak var contactSubtitleLabel: UILabel!
	@IBOutlet weak var contactTitleLabel: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		if let imageView = self.imageView {
			imageView.resize(size: 34.0)
			imageView.makeRound()
		}
	}
}
