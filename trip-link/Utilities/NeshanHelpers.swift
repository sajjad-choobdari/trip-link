//
//  NeshanHelper.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/17/23.
//

import Foundation
import UIKit

class VectorElementClickedListener: NTVectorElementEventListener {
	var onVectorElementClickedBlock: ((NTElementClickData) -> Bool)?

	override func onVectorElementClicked(_ clickInfo: NTElementClickData) -> Bool {
		return onVectorElementClickedBlock?(clickInfo) ?? false
	}
}

class MapEventListener: NTMapEventListener {
	var onMapClickedBlock: ((NTClickData) -> Void)?
	var onMapMovedBlock: (() -> Void)?
	var onMapStableBlock: (() -> Void)?
	var onMapIdleBlock: (() -> Void)?

	override func onMapClicked(_ clickInfo: NTClickData) {
		onMapClickedBlock?(clickInfo)
	}

	override func onMapMoved() {
		onMapMovedBlock?()
	}

	override func onMapStable() {
		onMapStableBlock?()
	}

	override func onMapIdle() {
		onMapIdleBlock?()
	}
}
