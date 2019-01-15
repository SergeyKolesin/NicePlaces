//
//  Place.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/14/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import CoreData
import MapKit

enum PlaceError: Error {
	case invalidJson
	case coreDataIssue
}

extension Place
{
	class func saveDefaultPlaces(dictionaty: [String : Any], context: NSManagedObjectContext) throws
	{
		guard let placeDictList = dictionaty["locations"] as? [[String : Any]] else {throw PlaceError.invalidJson}
		for placeDict in placeDictList
		{
			guard let title = placeDict["name"] as? String else {throw PlaceError.invalidJson}
			guard let lat = placeDict["lat"] as? Double else {throw PlaceError.invalidJson}
			guard let lng = placeDict["lng"] as? Double else {throw PlaceError.invalidJson}
			guard let entity = NSEntityDescription.entity(forEntityName: "Place", in: context) else {throw PlaceError.coreDataIssue}
			guard let place = NSManagedObject(entity: entity, insertInto: context) as? Place else {throw PlaceError.coreDataIssue}
			place.title = title
			place.lat = lat
			place.lng = lng
			place.descriptionString = ""
			place.editable = false
		}
		do {
			try context.save()
		} catch {
			throw PlaceError.coreDataIssue
		}
	}
	
	class func fetchPlace(context: NSManagedObjectContext, title: String) -> Place?
	{
		let request: NSFetchRequest<Place> = Place.fetchRequest()
		let pred = NSPredicate(format: "title == %@", title)
		request.predicate = pred
		let result = try? context.fetch(request)
		return result?.first
	}
}


extension Place: MKAnnotation
{
	public var coordinate: CLLocationCoordinate2D
	{
		get
		{
			return CLLocationCoordinate2D(latitude: lat, longitude: lng)
		}
	}
}
