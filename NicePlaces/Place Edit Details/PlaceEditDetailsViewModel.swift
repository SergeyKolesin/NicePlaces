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
	let lat: String
	let lng: String
	let descriptionString: Variable<String>
	
	let disposeBag = DisposeBag()
	
	init(place: Place)
	{
		self.place = place
		title = Variable<String>(place.title ?? "")
		lat = String(format: "%.10f", place.lat)
		lng = String(format: "%.10f", place.lng)
		descriptionString = Variable<String>(place.descriptionString ?? "")
		
		super.init()
	}
	
	func saveChanges() -> Observable<PlaceOperationResult>
	{
		return PlaceManager.shared.updatePlace(place, withTitle: title.value, withDescription: descriptionString.value)
			.observeOn(MainScheduler.instance)
			.flatMap({ _ -> Observable<PlaceOperationResult> in
				return Observable<PlaceOperationResult>.just(PlaceOperationResult(success: true, errorString: nil))
			})
			.catchError({ error -> Observable<PlaceOperationResult> in
				guard let error = error as? CoreDataError else {throw CoreDataError.unknown}
				return Observable<PlaceOperationResult>.create({ [weak self] observer -> Disposable in
					switch error
					{
					case .alreadyExist:
						observer.onNext(PlaceOperationResult(success: false, errorString: String(format: error.description, (self?.title.value)!)))
					case .notFound:
						observer.onNext(PlaceOperationResult(success: false, errorString: String(format: error.description, (self?.place.title)!)))
					case .unknown, .nameIsEmpty:
						observer.onNext(PlaceOperationResult(success: false, errorString: error.description))
					}

					return Disposables.create()
				})
			})
	}
}
