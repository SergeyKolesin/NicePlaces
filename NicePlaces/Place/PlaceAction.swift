//
//  PlaceAction.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/18/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation

struct PlaceAction
{
	let place: Place
	let type: PlaceActionType
	let indexPath: IndexPath?
	let newIndexPath: IndexPath?
}

enum PlaceActionType: UInt
{
	case insert
	
	case delete
	
	case move
	
	case update	
}
