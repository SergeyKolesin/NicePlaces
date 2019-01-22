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
	
	let coordinate = PublishSubject<CLLocationCoordinate2D>()
	
	let disposeBag = DisposeBag()
	
	var viewModel: AddPlaceViewModel!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		mapView.delegate = self
		setupNavBar()
		setupTitleAndDescription()
		setupLat()
		setupLng()
		coordinate.map {
				String(format: "%.10f", $0.latitude)
			}
			.bind(to: viewModel.lat)
			.disposed(by: disposeBag)
		coordinate.map {
			String(format: "%.10f", $0.longitude)
			}
			.bind(to: viewModel.lng)
			.disposed(by: disposeBag)
		
		Observable.combineLatest(viewModel.lat.asObservable(), viewModel.lng.asObservable()) { (lat, lng) -> CLLocationCoordinate2D in
				let coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lng)!)
				return coordinate
			}
			.subscribe(onNext: { [weak self] coordinate in
				self?.updateMap(coordinate)
			})
			.disposed(by: disposeBag)
//		PlaceManager.shared.generatePlace(1000, name: "qwerty")
	}
	
	func setupNavBar()
	{
		let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
		navigationItem.rightBarButtonItem = saveButton
		saveButton.rx.tap
			.flatMap { [unowned self] _ -> Observable<PlaceOperationResult> in
				return self.viewModel.saveNewPlace()
			}
			.subscribe(onNext: { [weak self] result in
				if result.success
				{
					self?.navigationController?.popViewController(animated: true)
				}
				else if let errorString = result.errorString
				{
					let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertController.Style.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
					self?.present(alert, animated: true, completion: nil)
				}
			})
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
		viewModel.lat.asObservable()
			.bind(to: latTextField.rx.text)
			.disposed(by: disposeBag)
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
		viewModel.lng.asObservable()
			.bind(to: lngTextField.rx.text)
			.disposed(by: disposeBag)
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

extension AddPlaceViewController: MKMapViewDelegate
{
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
	{
		guard annotation is MKPointAnnotation else { return nil }
		
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
		annotationView?.isDraggable = true
		
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState)
	{
		if newState == .ending
		{
			guard let pinCoordinate = view.annotation?.coordinate else {return}
			coordinate.onNext(pinCoordinate)
		}
	}
}
