//
//  ContentView.swift
//  CombineSwiftUI
//
//  Created by Kunal Kumar on 2021-01-16.
//

import SwiftUI
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

// Using this enum we could smartly encapsulate all the states into one type.

enum NASAStuff {
    case none
    case receivedData(NasaSampleAPI)
    case error(Error?)
    
}

//A class that conforms to ObservableObject , it will be able to notify updates before the object has changed.
class NASAViewModel: ObservableObject {
    //An AnyCancellable Subscriber to cancel the subscription on deallocation.
    var cancellable: AnyCancellable?
    @Published var state: NASAStuff = .none

    func getData() {
        cancellable = NetwortkLayer.pullDataFromServer()
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    self.state = .error(error)
                }
            }, receiveValue: { (model) in
                self.state = .receivedData(model)
            })
    }
}

class NasaSampleAPI: Codable, Identifiable {
    
    var id = UUID()
    let date, explanation: String?
    let hdurl: String?
    let mediaType, serviceVersion, title: String?
    let url: String?
    var image: Image? {
        if let hdurl = url, let url = URL(string: hdurl) {
            return self.load(url: url)
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url
    }
    
    func load(url: URL) -> Image? {
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                return Image(uiImage: image)
            }
        }
        return nil
    }
}

struct ContentView: View {
    private var cancellable: AnyCancellable?
    
    @EnvironmentObject var viewModel: NASAViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                switch viewModel.state {
                case .receivedData(let model):
                    if let image = model.image {
                        ZStack(alignment: .bottomTrailing) {
                            image
                                .resizable()
                                .frame(height: 300)
                            
                            if let date = model.date {
                                Text(date)
                                    .font(.title2)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .padding(.all)
                            }
                        }
                    }
                    
                    VStack {
                        if let title = model.title {
                            Text(title)
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.purple)
                        }
                        
                        if let description = model.explanation {
                            Text(description)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }.padding()
                default:
                    Text(self.buildContent(model: viewModel.state))
                    
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: {
            viewModel.getData()
        })
    }
    
    private func buildContent(model: NASAStuff) -> String {
        switch model {
        case .error(let e):
            return e?.localizedDescription ?? "No error description found"
        case .none:
            return "Loading..."
        default:
            return ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    class NasaSampleAPIMock: NasaSampleAPI {
        override var image: Image? {
            Image("placeholder")
        }
    }
    
    static var json: Data! = """
        {
            "title": "Testing Title",
            "date": "01-01-1960",
            "explanation": "Test Explanation"
        }
        """.data(using: .utf8)!
    static var model = try! JSONDecoder().decode(NasaSampleAPIMock.self, from: json)
    static var vm: NASAViewModel {
        let vm = NASAViewModel()
        vm.state = .receivedData(model)
        return vm
    }
    
    static var previews: some View {
        Group {
                 ContentView()
                    .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                    .previewDisplayName("iPhone SE")

                 ContentView()
                    .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                    .previewDisplayName("iPhone XS Max")
              }.environmentObject(vm)
    }
}

