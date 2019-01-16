//
//  AddPlaceViewModel.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/16/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation
import RxSwift

class AddPlaceViewModel
{
	let title = Variable<String>("")
	let lat: Variable<String>
	let lng: Variable<String>
	let descriptionString = Variable<String>("")
	
	init(lat: Double, lng: Double)
	{
		self.lat = Variable<String>(String(format: "%.6f", lat))
		self.lng = Variable<String>(String(format: "%.6f", lng))
	}
	
	func saveNewPlace()
	{
		
	}
}

