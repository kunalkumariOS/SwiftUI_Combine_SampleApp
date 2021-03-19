//
//  NasaModel.swift
//  CombineSwiftUI
//
//  Created by Kunal Kumar on 2021-01-17.
//

import Combine
import Foundation

// Using this enum we could smartly encapsulate all the states into one type.
enum NASAStuff {
    case none
    case receivedData(NasaSampleAPI)
    case error(Error?)
}

// A class that conforms to ObservableObject , it will be able to notify updates before the object has changed.
class NASAViewModel: ObservableObject {
    // An AnyCancellable Subscriber to cancel the subscription on deallocation.
    var cancellable: AnyCancellable?
    @Published var state: NASAStuff = .none

    func getData() {
        cancellable = NetwortkLayer.pullDataFromServer()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("finished")
                case let .failure(error):
                    self.state = .error(error)
                }
            }, receiveValue: { model in
                self.state = .receivedData(model)
            })
    }
}
