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
		setupNavBar()
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
	
	func setupNavBar()
	{
		let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
		navigationItem.rightBarButtonItem = saveButton
		saveButton.rx.tap
			.flatMap { [unowned self] _ -> Observable<PlaceOperationResult> in
				return self.viewModel.saveChanges()
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
		title = viewModel.place.title ?? ""
	}
	
}
