//
//  LocationManager.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/15/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import MapKit

class LocationManager: NSObject
{
	static let shared = LocationManager()
	private let locationManager = CLLocationManager()
	
	let region = Variable<MKCoordinateRegion>(MKCoordinateRegion())
	let coordinate = PublishSubject<CLLocationCoordinate2D>()
	
	private override init() {
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
}

extension LocationManager: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else {return}
		let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
		region.value = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15))
		coordinate.onNext(center)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Errors " + error.localizedDescription)
	}
}
