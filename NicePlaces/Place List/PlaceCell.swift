//
//  PlaceCell.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/15/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlaceCell: UITableViewCell
{
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var latValueLabel: UILabel!
	@IBOutlet weak var lngValueLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	
	var model: PlaceCellModel?
	{
		didSet
		{
			guard let model = model else {return}
			model.title.asObservable()
				.bind(to: titleLabel.rx.text)
				.disposed(by: model.disposeBag)
			model.lat.asObservable()
				.bind(to: latValueLabel.rx.text)
				.disposed(by: model.disposeBag)
			model.lng.asObservable()
				.bind(to: lngValueLabel.rx.text)
				.disposed(by: model.disposeBag)
			model.descriptionString.asObservable()
				.bind(to: descriptionLabel.rx.text)
				.disposed(by: model.disposeBag)
		}
	}
}
