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

class PlaceManager: NSObject
{
	static let shared = PlaceManager()
	lazy var places: Variable<[Place]> = {
		return Variable<[Place]>(self.fetchedResultsController.fetchedObjects ?? [Place]())
	}()
	
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
}

extension PlaceManager: NSFetchedResultsControllerDelegate
{
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
	{
		places.value = fetchedResultsController.fetchedObjects ?? [Place]()
	}
}