//
//  PlaceListViewController.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/14/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import UIKit
import RxSwift

class PlaceListViewController: UIViewController
{
	@IBOutlet weak var tableView: UITableView!
	let viewModel = PlaceListViewModel()
	let disposeBag = DisposeBag()
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		
		viewModel.placeActionSubject.subscribe(onNext: { [weak self] (insertIndexes, deleteIndexes, updateIndexes) in
			
			self?.tableView.beginUpdates()
			self?.tableView.insertRows(at: insertIndexes, with: .automatic)
			self?.tableView.deleteRows(at: deleteIndexes, with: .automatic)
			self?.tableView.reloadRows(at: updateIndexes, with: .automatic)
			self?.tableView.setEditing(false, animated: false)
			self?.tableView.endUpdates()
			
			})
			.disposed(by: disposeBag)
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		tableView.reloadData()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "showEditPlaceVC"
		{
			guard let place = sender as? Place else {return}
			guard let vc = segue.destination as? PlaceEditDetailsViewController else {return}
			vc.viewModel = PlaceEditDetailsViewModel(place: place)
		}
	}
	
}

extension PlaceListViewController: UITableViewDelegate
{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		guard let model = viewModel.cellModel(for: indexPath.row, sync: true) else {return 75.0}
		return 75.0 + model.descriptionString.value.height(constraintedWidth: self.tableView.frame.size.width, font: UIFont.systemFont(ofSize: 17))
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let cell = tableView.cellForRow(at: indexPath)
		cell?.isSelected = false
		performSegue(withIdentifier: "showEditPlaceVC", sender: viewModel.place(for: indexPath.row))
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == .delete)
		{
			viewModel.deleteCell(index: indexPath.row)
				.subscribe(onNext: { [weak self] result in
					if let errorString = result.errorString
					{
						let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertController.Style.alert)
						alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
						self?.present(alert, animated: true, completion: nil)
					}
				})
				.disposed(by: disposeBag)
		}
	}
}

extension PlaceListViewController: UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return viewModel.placeCounter.value
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceCell else {return UITableViewCell()}
		
		let model = viewModel.cellModel(for: indexPath.row, sync: false)
		cell.model = model
		
		return cell
	}
	
}
