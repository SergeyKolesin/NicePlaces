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
	lazy var unsortedPlaces: Variable<[Place]> = {
		return Variable<[Place]>(self.fetchedResultsController.fetchedObjects ?? [Place]())
	}()
	let places = Variable<[Place]>([Place]())
	
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
		
		Observable.combineLatest(unsortedPlaces.asObservable(), LocationManager.shared.coordinate.asObservable()) { (places, coordinate) -> [Place] in
			let sorted = places.sorted(by: { (first, second) -> Bool in
				let myLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
				let firstLocation = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
				let secondLocation = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude)
				let firstDistance = myLocation.distance(from: firstLocation)
				let secondDistance = myLocation.distance(from: secondLocation)
				return firstDistance < secondDistance
			})
			return sorted
			}
			.bind(to: places)
			.disposed(by: disposeBag)
	}
	
	lazy var fetchedResultsController: NSFetchedResultsController<Place> = {
		
		let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		
		fetchedResultsController.delegate = self
		return fetchedResultsController
	}()
	
	func saveDefaultPlaces(dictionary: [String : Any])
	{
		persistentContainer.performBackgroundTask { context in
			do
			{
				try Place.saveDefaultPlaces(dictionaty: dictionary, context: context)
			}
			catch
			{
				print("Core Data is Failed")
			}
		}
	}
	
	func deletePlace(for index: Int)
	{
		if index >= 0 && index < places.value.count
		{
			let place = places.value[index]
			guard let title = place.title else {return}
			
			persistentContainer.performBackgroundTask { context in
				if let place = Place.fetchPlace(context: context, title: title)
				{
					context.delete(place)
					try? context.save()
				}
			}
		}
	}
	
	func update(place: Place, withTitle newTitle: String, withDescription newDescription: String)
	{
		guard let title = place.title else {return}
		persistentContainer.performBackgroundTask { context in
			guard let existPlace = Place.fetchPlace(context: context, title: title) else {return}
			if let placeWithNewTitle = Place.fetchPlace(context: context, title: newTitle)
			{
				if placeWithNewTitle != existPlace
				{
					return
				}
			}
			existPlace.title = newTitle
			existPlace.descriptionString = newDescription
			try? context.save()
		}
	}
	
	func addNewPlace(title: String, descriptionString: String, lat: Double, lng: Double)
	{
		if title.isEmpty
		{
			return
		}
		persistentContainer.performBackgroundTask { context in
			if let _ = Place.fetchPlace(context: context, title: title)
			{
				return
			}
			Place.addNewPlace(context: context, title: title, descriptionString: descriptionString, lat: lat, lng: lng)
		}
	}
	
}

extension PlaceManager: NSFetchedResultsControllerDelegate
{
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
	{
		unsortedPlaces.value = fetchedResultsController.fetchedObjects ?? [Place]()
	}
}
