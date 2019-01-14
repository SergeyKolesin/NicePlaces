//
//  MapViewController.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/14/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController
{
	@IBOutlet weak var mapView: MKMapView!
	let locationManager = CLLocationManager()
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		mapView.delegate = self
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		mapView.showsUserLocation = true
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		locationManager.startUpdatingLocation()
	}
	
}

extension MapViewController: MKMapViewDelegate
{
	
}

extension MapViewController: CLLocationManagerDelegate
{
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else {return}
		let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
		
		mapView.setRegion(region, animated: true)
		locationManager.stopUpdatingLocation()
		
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Errors " + error.localizedDescription)
	}
	
}
