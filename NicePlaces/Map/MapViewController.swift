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
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		viewModel.startUpdatingLocation()
	}
	
	func configPins()
	{
		mapView.removeAnnotations(mapView.annotations)
		for place in viewModel.places.value
		{
			mapView.addAnnotation(place)
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
