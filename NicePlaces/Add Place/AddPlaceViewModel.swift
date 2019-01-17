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
	let dismissSubject = PublishSubject<Void>()
	let showAlertSubject = PublishSubject<String>()
	
	let disposeBag = DisposeBag()
	
	init(lat: Double, lng: Double)
	{
		self.lat = Variable<String>(String(format: "%.6f", lat))
		self.lng = Variable<String>(String(format: "%.6f", lng))
		
	}
	
	func saveNewPlace()
	{
		PlaceManager.shared.addNewPlace(title: title.value, descriptionString: descriptionString.value, lat: Double(self.lat.value)!, lng: Double(self.lng.value)!)
			.subscribe(onError: { [weak self] error in
				if let error = error as? CoreDataError
				{
					self?.showAlertSubject.onNext(String(format: error.description, (self?.title.value)!))
				}
			}, onCompleted: { [weak self] in
				self?.dismissSubject.onCompleted()
			})
			.disposed(by: disposeBag)
	}
}

