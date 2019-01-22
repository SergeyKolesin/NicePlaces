//
//  PlaceCellModel.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/15/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation
import RxSwift

class PlaceCellModel: NSObject
{
	let title = Variable<String>("")
	let lat = Variable<String>("")
	let lng = Variable<String>("")
	let descriptionString = Variable<String>("")
	let disposeBag = DisposeBag()
}
