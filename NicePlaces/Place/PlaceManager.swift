//
//  PlaceManager.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/14/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import CoreLocation

class PlaceManager: NSObject
{
	let disposeBag = DisposeBag()
	static let shared = PlaceManager()
	private let coordinate = Variable<CLLocationCoordinate2D>(CLLocationCoordinate2D())
	lazy var places: Variable<[Place]> = {
		return Variable<[Place]>(self.fetchedResultsController.fetchedObjects ?? [Place]())
	}()
	
	let placeActionEmitter = PublishSubject<PlaceAction>()
	
	private let persistentContainer = NSPersistentContainer(name: "NicePlaces")
	
	override init() {
		super.init()
		persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
			if let error = error
			{
				print("Unable to Load Persistent Store")
				print("\(error), \(error.localizedDescription)")
			}
			else
			{
				do {
					try self.fetchedResultsController.performFetch()
				} catch {
					let fetchError = error as NSError
					print("Unable to Perform Fetch Request")
					print("\(fetchError), \(fetchError.localizedDescription)")
				}
			}
		}
		persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
		
		LocationManager.shared.coordinate
			.bind(to: coordinate)
			.disposed(by: disposeBag)
		
		LocationManager.shared.coordinate
			.throttle(5, scheduler: MainScheduler.instance)
			.subscribe(onNext: { [weak self] coordinate in
				
				let titles = PlaceManager.shared.places.value.compactMap({ place -> String? in
					return place.title
				})
				
				self?.persistentContainer.performBackgroundTask { context in
					
					for title in titles
					{
						guard let place = Place.fetchPlace(context: context, title: title) else {continue}
						place.distance = PlaceManager.shared.calculateCurrentDistance(for: place, andCoordinate: coordinate)
					}
					
					try? context.save()
					
				}
			})
			.disposed(by: disposeBag)
	}
	
	lazy var fetchedResultsController: NSFetchedResultsController<Place> = {
		
		let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: true)]
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		
		fetchedResultsController.delegate = self
		return fetchedResultsController
	}()
	
	func calculateCurrentDistance(for place: Place, andCoordinate coordinate: CLLocationCoordinate2D = PlaceManager.shared.coordinate.value) -> Double
	{
		let myLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		let placeLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
		let distance = myLocation.distance(from: placeLocation)
		return distance
	}
	
	func saveDefaultPlaces(dictionary: [String : Any]) -> Observable<Void>
	{
		return Observable.create({ [weak self] observer -> Disposable in
			self?.persistentContainer.performBackgroundTask { context in
				do
				{
					try Place.saveDefaultPlaces(dictionaty: dictionary, context: context)
					observer.onNext(())
					observer.onCompleted()
				}
				catch
				{
					print("Core Data is Failed")
					observer.onError(error)
				}
			}
			return Disposables.create()
		})
	}
	
	func deletePlace(_ place: Place) -> Observable<Void>
	{
		return Observable.create({ observer in
			let disposable = Disposables.create()
			let title = place.title!
			self.persistentContainer.performBackgroundTask { context in
				if let place = Place.fetchPlace(context: context, title: title)
				{
					context.delete(place)
					try? context.save()
					observer.onNext(())
					observer.onCompleted()
				}
				else
				{
					observer.onError(CoreDataError.notFound)
				}
			}
			return disposable
		})
	}
	
	func updatePlace(_ place: Place, withTitle newTitle: String, withDescription newDescription: String) -> Observable<Void>
	{
		return Observable.create({ observer in
			let disposable = Disposables.create()
			
			let title = place.title!
			
			if newTitle.isEmpty
			{
				observer.onError(CoreDataError.nameIsEmpty)
				return disposable
			}
			
			self.persistentContainer.performBackgroundTask { context in
				guard let existPlace = Place.fetchPlace(context: context, title: title) else {
					observer.onError(CoreDataError.notFound)
					return
				}
				if let placeWithNewTitle = Place.fetchPlace(context: context, title: newTitle)
				{
					if placeWithNewTitle != existPlace
					{
						observer.onError(CoreDataError.alreadyExist)
						return
					}
				}
				existPlace.title = newTitle
				existPlace.descriptionString = newDescription
				try? context.save()
				observer.onNext(())
				observer.onCompleted()
			}
			
			return disposable
		})
	}
	
	func addNewPlace(title: String, descriptionString: String, lat: Double, lng: Double) -> Observable<Void>
	{
		return Observable.create({ observer in
			let disposable = Disposables.create()
			if title.isEmpty
			{
				observer.onError(CoreDataError.nameIsEmpty)
				return disposable
			}
			self.persistentContainer.performBackgroundTask { context in
				if let _ = Place.fetchPlace(context: context, title: title)
				{
					observer.onError(CoreDataError.alreadyExist)
					return
				}
				Place.addNewPlace(context: context, title: title, descriptionString: descriptionString, lat: lat, lng: lng)
				observer.onNext(())
				observer.onCompleted()
			}
			return disposable
		})
	}
}

enum CoreDataError: Error
{
	case alreadyExist
	case nameIsEmpty
	case notFound
	case unknown
	
	var description: String
	{
		get
		{
			switch self
			{
			case .alreadyExist:
				return "Place with name %@ is already exist."
			case .nameIsEmpty:
				return "Place must have name."
			case .notFound:
				return "Place with name %@ is not found."
			case .unknown:
				return "Unknown data base error."
			}
		}
	}
}

extension PlaceManager: NSFetchedResultsControllerDelegate
{
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
	{
		places.value = fetchedResultsController.fetchedObjects ?? [Place]()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
	{
		guard let _ = anObject as? Place else {return}
		guard let actionType = PlaceActionType(rawValue: type.rawValue - 1) else {return}
		let action = PlaceAction(type: actionType, indexPath: indexPath, newIndexPath: newIndexPath)
		places.value = fetchedResultsController.fetchedObjects ?? [Place]()
		placeActionEmitter.onNext(action)
	}
}
