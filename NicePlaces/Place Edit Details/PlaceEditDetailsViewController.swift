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
		latValueLabel.text = viewModel.lat
		lngValueLabel.text = viewModel.lng
		titleTextField.text = viewModel.title.value
		descriptionTextField.text = viewModel.descriptionString.value
		
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
