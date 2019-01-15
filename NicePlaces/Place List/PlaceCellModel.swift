//
//  PlaceCellModel.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/15/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation

class PlaceCellModel: NSObject
{
	var title: String
	var lat: String
	var lng: String
	var descriptionString: String
	
	init(title: String, lat: String, lng: String, descriptionString: String)
	{
		self.title = title
		self.lat = lat
		self.lng = lng
		self.descriptionString = descriptionString
		super.init()
	}
}
