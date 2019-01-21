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
	
	let disposeBag = DisposeBag()
	
	init(lat: Double, lng: Double)
	{
		self.lat = Variable<String>(String(format: "%.10f", lat))
		self.lng = Variable<String>(String(format: "%.10f", lng))
	}
	
	func saveNewPlace() -> Observable<SavePlaceResult>
	{
		return PlaceManager.shared.addNewPlace(title: title.value, descriptionString: descriptionString.value, lat: Double(self.lat.value)!, lng: Double(self.lng.value)!)
			.observeOn(MainScheduler.instance)
			.flatMap({ _ -> Observable<SavePlaceResult> in
				return Observable<SavePlaceResult>.just(SavePlaceResult(success: true, errorString: nil))
			})
			.catchError({ error -> Observable<SavePlaceResult> in
				guard let error = error as? CoreDataError else {throw CoreDataError.unknown}
				return Observable<SavePlaceResult>.create({ [weak self] observer -> Disposable in
					observer.onNext(SavePlaceResult(success: false, errorString: String(format: error.description, (self?.title.value)!)))
					return Disposables.create()
				})
			})
	}

}

struct SavePlaceResult
{
	let success: Bool
	let errorString: String?
}
