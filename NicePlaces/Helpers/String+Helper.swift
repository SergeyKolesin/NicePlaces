//
//  String+Helper.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/15/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import UIKit

extension String {
	func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
		let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
		label.numberOfLines = 0
		label.text = self
		label.font = font
		label.sizeToFit()
		
		return label.frame.height
	}
}
