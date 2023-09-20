//
//  TripTableViewCell.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/19/23.
//

import UIKit

class TripTableViewCell: UITableViewCell {

	// Outlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var originAddressLabel: UILabel!
	@IBOutlet weak var destinationAddressLabel: UILabel!

	//
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
    
}
