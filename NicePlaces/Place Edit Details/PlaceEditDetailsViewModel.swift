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
	let dismissSubject = PublishSubject<Void>()
	let showAlertSubject = PublishSubject<String>()
	
	let disposeBag = DisposeBag()
	
	init(place: Place)
	{
		self.place = place
		title = Variable<String>(place.title ?? "")
		lat = String(format: "%.6f", place.lat)
		lng = String(format: "%.6f", place.lng)
		descriptionString = Variable<String>(place.descriptionString ?? "")
		
		super.init()
	}
	
	func saveChanges()
	{
		PlaceManager.shared.update(place: place, withTitle: title.value, withDescription: descriptionString.value)
			.subscribe(onError: { [weak self] error in
				if let error = error as? CoreDataError
				{
					var name = ""
					switch error
					{
					case .alreadyExist:
						name = (self?.title.value)!
					case .nameIsEmpty:
						break
					case .notFound:
						name = (self?.place.title)!
					case .unknown:
						break
					}
					self?.showAlertSubject.onNext(String(format: error.description, name))
				}
			}, onCompleted: { [weak self] in
				self?.dismissSubject.onCompleted()
			})
			.disposed(by: disposeBag)
	}
}
