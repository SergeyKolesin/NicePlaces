//
//  MapViewController.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/14/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class MapViewController: UIViewController
{
	@IBOutlet weak var mapView: MKMapView!
	let viewModel = MapViewModel()
	let disposeBag = DisposeBag()
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		mapView.delegate = self
		mapView.showsUserLocation = true
		
		let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTapOnMap))
		mapView.addGestureRecognizer(longTap)

		viewModel.region.asObservable()
			.subscribe { event in
				if let element = event.element
				{
					self.mapView.setRegion(element, animated: true)
				}
			}
			.disposed(by: disposeBag)
		
		viewModel.places.asObservable()
			.subscribe { _ in
				self.configPins()
			}
			.disposed(by: disposeBag)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "showAddPlaceVC"
		{
			guard let longTap = sender as? UILongPressGestureRecognizer else {return}
			guard let vc = segue.destination as? AddPlaceViewController else {return}
			let point = longTap.location(in: mapView)
			let coordinate = mapView.convert(point, toCoordinateFrom: nil)
			vc.viewModel = AddPlaceViewModel(lat: coordinate.latitude, lng: coordinate.longitude)
		}
	}
	
	func configPins()
	{
		mapView.removeAnnotations(mapView.annotations)
		for place in viewModel.places.value
		{
			mapView.addAnnotation(place)
		}
	}
	
	@objc func longTapOnMap(sender: UILongPressGestureRecognizer)
	{
		if sender.state == .began
		{
			performSegue(withIdentifier: "showAddPlaceVC", sender: sender)
		}
	}
	
}

extension MapViewController: MKMapViewDelegate
{
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard annotation is Place else { return nil }
		
		let identifier = "Annotation"
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
		
		if annotationView == nil
		{
			annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			annotationView!.canShowCallout = true
		}
		else
		{
			annotationView!.annotation = annotation
		}
		
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		print("qqq")
	}
}
