//
//  PlaceEditDetailsViewController.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/15/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlaceEditDetailsViewController: UIViewController
{
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var descriptionTextField: UITextField!
	@IBOutlet weak var latValueLabel: UILabel!
	@IBOutlet weak var lngValueLabel: UILabel!
	
	var viewModel: PlaceEditDetailsViewModel!
	let disposeBag = DisposeBag()
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
		title = viewModel.place.title ?? ""
		viewModel.lat.asObservable()
			.bind(to: latValueLabel.rx.text)
			.disposed(by: disposeBag)
		viewModel.lng.asObservable()
			.bind(to: lngValueLabel.rx.text)
			.disposed(by: disposeBag)
		viewModel.title.asObservable()
			.bind(to: titleTextField.rx.text)
			.disposed(by: disposeBag)
		viewModel.descriptionString.asObservable()
			.bind(to: descriptionTextField.rx.text)
			.disposed(by: disposeBag)
		titleTextField.rx.text
			.orEmpty
			.bind(to: viewModel.title)
			.disposed(by: disposeBag)
		descriptionTextField.rx.text
			.orEmpty
			.bind(to: viewModel.descriptionString)
			.disposed(by: disposeBag)
		
	}
	
	@objc func saveTapped()
	{
		viewModel.saveChanges()
		navigationController?.popViewController(animated: true)
	}
}
