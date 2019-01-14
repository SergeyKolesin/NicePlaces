//
//  MapViewModel.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/14/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation
import RxSwift
//import MapKit
import CoreLocation

class MapViewModel: NSObject
{
	let locationManager = CLLocationManager()
	var lat = Variable<Double>(0)
	var lng = Variable<Double>(0)
	
	override init()
	{
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
	}
	
	func startUpdatingLocation()
	{
		locationManager.startUpdatingLocation()
	}
}

extension MapViewModel: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else {return}
		lat.value = location.coordinate.latitude
		lng.value = location.coordinate.longitude
		locationManager.stopUpdatingLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Errors " + error.localizedDescription)
	}
}
