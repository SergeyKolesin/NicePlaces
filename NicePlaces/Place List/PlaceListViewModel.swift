//
//  PlaceListViewModel.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/14/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation
import RxSwift

class PlaceListViewModel: NSObject
{
	let disposeBag = DisposeBag()
	var places = Variable<[PlaceCellModel]>([PlaceCellModel]())
	
	override init()
	{
		super.init()
		PlaceManager.shared.places.asObservable()
			.map({ placeList -> [PlaceCellModel] in
				return placeList.map({ place -> PlaceCellModel in
					let title = place.title ?? ""
					let lat = String(format: "%.6f", place.lat)
					let lng = String(format: "%.6f", place.lng)
					let descriptionString = place.descriptionString ?? ""
					
					return PlaceCellModel(title: title, lat: lat, lng: lng, descriptionString: descriptionString)
				})
			})
			.bind(to: places)
			.disposed(by: disposeBag)
	}
	
	func deleteCell(index: Int)
	{
		PlaceManager.shared.deletePlace(for: index)
	}
	
	func place(for index: Int) -> Place?
	{
		if index >= 0 && index < PlaceManager.shared.places.value.count
		{
			return PlaceManager.shared.places.value[index]
		}
		return nil
	}
	
}
