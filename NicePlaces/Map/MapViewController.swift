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

		Observable.of(viewModel.lat.asObservable(), viewModel.lng.asObservable())
			.merge()
			.subscribe { _ in
				let center = CLLocationCoordinate2D(latitude: self.viewModel.lat.value, longitude: self.viewModel.lng.value)
				let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
				self.mapView.setRegion(region, animated: true)
			}
			.disposed(by: disposeBag)
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		viewModel.startUpdatingLocation()
	}
	
}

extension MapViewController: MKMapViewDelegate
{
	
}
