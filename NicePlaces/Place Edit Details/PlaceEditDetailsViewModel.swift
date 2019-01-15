//
//  PlaceEditDetailsViewModel.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/15/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation
import RxSwift

class PlaceEditDetailsViewModel: NSObject
{
	let place: Place
	let title: Variable<String>
	let lat: Variable<String>
	let lng: Variable<String>
	let descriptionString: Variable<String>
	
	init(place: Place)
	{
		self.place = place
		title = Variable<String>(place.title ?? "")
		lat = Variable<String>(String(format: "%.6f", place.lat))
		lng = Variable<String>(String(format: "%.6f", place.lng))
		descriptionString = Variable<String>(place.descriptionString ?? "")
		
		super.init()
	}
	
	func saveChanges()
	{
		PlaceManager.shared.update(place: place, withTitle: title.value, withDescription: descriptionString.value)
	}
}
