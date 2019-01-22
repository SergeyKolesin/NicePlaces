//
//  NetworkManager.swift
//  NicePlaces
//
//  Created by Sergei Kolesin on 1/22/19.
//  Copyright © 2019 Sergei Kolesin. All rights reserved.
//

import Foundation
import RxSwift

class NetworkManager: NSObject
{
	static let shared = NetworkManager()
	
	func getDefaultPlacesJson() -> Observable<[String : Any]>
	{
		return Observable.create({ observer -> Disposable in
			let disposable = Disposables.create()
			guard let url = URL(string: "http://bit.ly/test-locations") else
			{
				observer.onError(NetworkManagerError.invalidUrl)
				return disposable
			}
			let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
				guard let unwrappedData = data else
				{
					observer.onError(NetworkManagerError.missedData)
					return
				}
				do {
					guard let json = try JSONSerialization.jsonObject(with: unwrappedData, options: .allowFragments) as? [String : Any] else
					{
						observer.onError(NetworkManagerError.invalidJson)
						return
					}
					print(json)
					observer.onNext(json)
					observer.onCompleted()
				} catch {print("json error: \(error)")
					observer.onError(error)
				}
			}
			task.resume()
			return disposable
		})
	}
}

enum NetworkManagerError: Error
{
	case invalidUrl
	case missedData
	case invalidJson
}

