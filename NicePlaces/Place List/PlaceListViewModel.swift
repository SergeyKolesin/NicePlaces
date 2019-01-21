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
	let placeActionSubject = PublishSubject<PlaceAction>()
	
	override init()
	{
		super.init()
		PlaceManager.shared.places.asObservable()
			.map({ placeList -> [PlaceCellModel] in
				return placeList.map({ place -> PlaceCellModel in
					let title = place.title ?? ""
					let lat = String(format: "%.10f", place.lat)
					let lng = String(format: "%.10f", place.lng)
					let descriptionString = place.descriptionString ?? ""
					
					return PlaceCellModel(title: title, lat: lat, lng: lng, descriptionString: descriptionString)
				})
			})
			.bind(to: places)
			.disposed(by: disposeBag)
		
		PlaceManager.shared.placeActionEmitter
			.bind(to: placeActionSubject)
			.disposed(by: disposeBag)
	}
	
	func deleteCell(index: Int) -> Observable<PlaceOperationResult>
	{
		guard let place = self.place(for: index) else {
			return Observable<PlaceOperationResult>.just(PlaceOperationResult(success: false, errorString: "Incorrect place index"))
		}
		return PlaceManager.shared.deletePlace(place)
			.observeOn(MainScheduler.instance)
			.flatMap({ _ -> Observable<PlaceOperationResult> in
				return Observable<PlaceOperationResult>.just(PlaceOperationResult(success: true, errorString: nil))
			})
			.catchError({ error -> Observable<PlaceOperationResult> in
				guard let error = error as? CoreDataError else {throw CoreDataError.unknown}
				return Observable<PlaceOperationResult>.create({ observer -> Disposable in
					observer.onNext(PlaceOperationResult(success: false, errorString: error.description))
					return Disposables.create()
				})
			})
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
