//
//  AddPlaceViewController.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/16/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class AddPlaceViewController: UIViewController
{
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var latTextField: UITextField!
	@IBOutlet weak var lngTextField: UITextField!
	@IBOutlet weak var descriptionTextField: UITextField!
	
	@IBOutlet weak var mapView: MKMapView!
	let disposeBag = DisposeBag()
	
	var viewModel: AddPlaceViewModel!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupNavBar()
		setupTitleAndDescription()
		setupLat()
		setupLng()
		
		Observable.combineLatest(viewModel.lat.asObservable(), viewModel.lng.asObservable()) { (lat, lng) -> CLLocationCoordinate2D in
				let coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lng)!)
				return coordinate
			}
			.subscribe { [weak self] event in
				guard let coordinate = event.element else {return}
				self?.updateMap(coordinate)
			}
			.disposed(by: disposeBag)
	}
	
	func setupNavBar()
	{
		let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
		navigationItem.rightBarButtonItem = saveButton
		saveButton.rx.tap
			.subscribe { [weak self] _ in
				self?.viewModel.saveNewPlace()
				self?.navigationController?.popViewController(animated: true)
			}
			.disposed(by: disposeBag)
		title = "New Place"
	}
	
	func setupTitleAndDescription()
	{
		titleTextField.rx.text
			.orEmpty
			.bind(to: viewModel.title)
			.disposed(by: disposeBag)
		
		descriptionTextField.rx.text
			.orEmpty
			.bind(to: viewModel.descriptionString)
			.disposed(by: disposeBag)
	}
	
	func setupLat()
	{
		latTextField.rx.controlEvent([.editingDidEnd])
			.asObservable()
			.subscribe { [weak self] _ in
				self?.latTextField.text = self?.viewModel.lat.value
			}
			.disposed(by: disposeBag)
		latTextField.rx.text
			.orEmpty
			.filter {
				if let _ = Double($0)
				{
					return true
				}
				return false
			}
			.bind(to: viewModel.lat)
			.disposed(by: disposeBag)
		latTextField.text = viewModel.lat.value
	}
	
	func setupLng()
	{
		lngTextField.rx.controlEvent([.editingDidEnd])
			.asObservable()
			.subscribe { [weak self] _ in
				self?.lngTextField.text = self?.viewModel.lng.value
			}
			.disposed(by: disposeBag)
		lngTextField.rx.text
			.orEmpty
			.filter {
				if let _ = Double($0)
				{
					return true
				}
				return false
			}
			.bind(to: viewModel.lng)
			.disposed(by: disposeBag)
		lngTextField.text = viewModel.lng.value
	}
	
	func updateMap(_ coordinate: CLLocationCoordinate2D)
	{
		mapView.removeAnnotations(mapView.annotations)
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate
		mapView.addAnnotation(annotation)
		
		let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
		mapView.setRegion(region, animated: true)
	}

}
