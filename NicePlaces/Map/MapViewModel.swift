//
//  MapViewModel.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/14/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import MapKit

class MapViewModel: NSObject
{
	let region = Variable<MKCoordinateRegion>(MKCoordinateRegion())
	var places = Variable<[Place]>([Place]())
	let disposeBag = DisposeBag()
	
	override init()
	{
		super.init()
		PlaceManager.shared.places.asObservable()
			.bind(to: places)
			.disposed(by: disposeBag)
		LocationManager.shared.region.asObservable()
			.bind(to: region)
			.disposed(by: disposeBag)
	}
}
