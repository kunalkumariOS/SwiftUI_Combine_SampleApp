//
//  Network.swift
//  CombineSwiftUI
//
//  Created by Kunal Kumar on 2021-01-17.
//

import Foundation
import Combine

class NetwortkLayer {
    static let apiKey = "TpGjTiyq6pidRFaKjwq60FhVzLannwr0FSnDmIeD"
    static let url: URL! = URL(string: "https://api.nasa.gov/planetary/apod?api_key=\(apiKey)")
    static func pullDataFromServer() -> AnyPublisher<NasaSampleAPI, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: NasaSampleAPI.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
