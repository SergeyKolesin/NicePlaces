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
	let annotationChanges = PublishSubject<([MKAnnotation], [MKAnnotation])>()
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
		PlaceManager.shared.placeActionEmitter
			.flatMap { actions -> Observable<([MKAnnotation], [MKAnnotation])> in
				
				return Observable.create({ observer -> Disposable in
					
					var insertAnnotations = [MKAnnotation]()
					var deleteAnnotations = [MKAnnotation]()
					
					for action in actions
					{
						switch action.type
						{
						case .insert:
							insertAnnotations.append(action.place)
						case .delete:
							deleteAnnotations.append(action.place)
						default:
							break
						}
					}
					observer.onNext((insertAnnotations, deleteAnnotations))
					observer.onCompleted()
					return Disposables.create()
				})
				
				
			}
			.bind(to: annotationChanges)
			.disposed(by: disposeBag)
	}
}
