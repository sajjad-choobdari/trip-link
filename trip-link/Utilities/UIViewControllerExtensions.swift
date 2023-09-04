//
//  UIViewControllerExtensions.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/30/23.
//

import Foundation
import UIKit

extension UIViewController {
	func addChildVC(add child: UIViewController, into container: UIView) {
		addChild(child)
		container.addSubview(child.view)
		child.view.frame = container.bounds
		child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		child.didMove(toParent: self)
	}

	func removeChildVC(_ child: UIViewController) {
		guard parent != nil else {
			return
		}
		child.willMove(toParent: nil)
		child.view.removeFromSuperview()
		child.removeFromParent()
	}

	func embedChildVCIntoContainerView<ChildVC: UIViewController>(_ childVCType: ChildVC.Type, into containerView: UIView) {
		guard let childVC = storyboard?.instantiateViewController(withIdentifier: String(describing: childVCType)) as? ChildVC else {
			return
		}

		addChildVC(add: childVC, into: containerView)
	}

		// Call this in viewWillDisappear
	func removeEmbeddedChildViewController(from containerView: UIView) {
		guard let childViewController = objc_getAssociatedObject(self, "\(containerView)") as? UIViewController else {
			return
		}
		removeChildVC(childViewController)
		objc_setAssociatedObject(self, "\(containerView)", nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
}
