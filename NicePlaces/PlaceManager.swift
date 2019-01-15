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
	}
	
	// MARK: - Core Data stack
	
//	lazy var persistentContainer: NSPersistentContainer = {
//		/*
//		The persistent container for the application. This implementation
//		creates and returns a container, having loaded the store for the
//		application to it. This property is optional since there are legitimate
//		error conditions that could cause the creation of the store to fail.
//		*/
//		let container = NSPersistentContainer(name: "NicePlaces")
//		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//			if let error = error as NSError? {
//				// Replace this implementation with code to handle the error appropriately.
//				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//				/*
//				Typical reasons for an error here include:
//				* The parent directory does not exist, cannot be created, or disallows writing.
//				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
//				* The device is out of space.
//				* The store could not be migrated to the current model version.
//				Check the error message to determine what the actual problem was.
//				*/
//				fatalError("Unresolved error \(error), \(error.userInfo)")
//			}
//			else
//			{
//				do {
//					try self.fetchedResultsController.performFetch()
//				} catch {
//					let fetchError = error as NSError
//					print("Unable to Perform Fetch Request")
//					print("\(fetchError), \(fetchError.localizedDescription)")
//				}
//			}
//		})
//		return container
//	}()
	
	// MARK: - Core Data Saving support
	
//	func saveContext () {
//		let context = persistentContainer.viewContext
//		if context.hasChanges {
//			do {
//				try context.save()
//			} catch {
//				// Replace this implementation with code to handle the error appropriately.
//				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//				let nserror = error as NSError
//				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//			}
//		}
//	}
	
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
