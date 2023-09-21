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

protocol ResizableImageView {
	func resize(size: CGFloat)
}
protocol ResizableImage {
	func createResizedImage(withTargetSize targetSize: CGSize) -> UIImage?
}

extension Roundable where Self: UIImageView {
	func makeRound() {
		self.contentMode = .scaleAspectFill
		self.clipsToBounds = true
		self.layer.cornerRadius = self.frame.size.width / 2
	}
}
extension ResizableImageView where Self: UIImageView {
	func resize(size: CGFloat) {
		let newSize = CGSize(width: size, height: size)
		self.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
	}
}
extension ResizableImage where Self: UIImage {
	func createResizedImage(withTargetSize targetSize: CGSize) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
		defer { UIGraphicsEndImageContext() }

		self.draw(in: CGRect(origin: .zero, size: targetSize))

		guard let contextImage = UIGraphicsGetImageFromCurrentImageContext(),
					let resizedCGImage = contextImage.cgImage else {
			print("Error: Failed to resize the image.")
			return nil
		}

		return UIImage(cgImage: resizedCGImage)
	}
}

extension UIImageView: Roundable, ResizableImageView {}
extension UIImage: ResizableImage {}

class CircularImageView: UIImageView {
	override func layoutSubviews() {
		super.layoutSubviews()
		self.makeRound()
	}
}
