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
			.subscribe(onNext: { [weak self] in
				self?.mapView.setRegion($0, animated: true)
			})
			.disposed(by: disposeBag)
		
		viewModel.annotationChanges
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] (insertAnnotations, deleteAnnotations) in
				for annotation in insertAnnotations
				{
					self?.mapView.addAnnotation(annotation)
				}
				for annotation in deleteAnnotations
				{
					self?.mapView.removeAnnotation(annotation)
				}
			})
			.disposed(by: disposeBag)
		
		self.mapView.addAnnotations(viewModel.places.value)
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		self.mapView.setRegion(viewModel.region.value, animated: true)
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
		else if segue.identifier == "showEditPlaceVC"
		{
			guard let place = sender as? Place else {return}
			guard let vc = segue.destination as? PlaceEditDetailsViewController else {return}
			vc.viewModel = PlaceEditDetailsViewModel(place: place)
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
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
	{
		guard annotation is Place else { return nil }
		
		let identifier = "Annotation"
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
		
		if annotationView == nil
		{
			annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
		}
		else
		{
			annotationView!.annotation = annotation
		}
		
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
	{
		guard view.annotation is Place else { return }
		mapView.deselectAnnotation(view.annotation, animated: false)
		performSegue(withIdentifier: "showEditPlaceVC", sender: view.annotation)
	}
}
