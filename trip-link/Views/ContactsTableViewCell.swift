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
			imageView.resize(size: 40.0)
			imageView.makeRound()
		}
	}
}
