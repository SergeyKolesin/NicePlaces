//
//  ViewController.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/11/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		example(of: "PublishSubject") {
		
			let subject = PublishSubject<String>()
			subject.onNext("Is anyone listening?")
			let _ = subject.subscribe(onNext: { string in
				print(string)
			})
			subject.on(.next("1"))
			subject.onNext("2")
			let _ = subject.subscribe({ event in
				print("QQQ \(event.element ?? event.debugDescription)")
			})
			subject.onNext("3")
		}
	}

	public func example(of description: String, action: () -> Void) {
		print("\n--- Example of:", description, "---")
		action()
	}
	
}

