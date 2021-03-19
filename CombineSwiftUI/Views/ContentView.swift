//
//  ContentView.swift
//  CombineSwiftUI
//
//  Created by Kunal Kumar on 2021-01-16.
//

import Combine
import SwiftUI

struct ContentView: View {
    private var cancellable: AnyCancellable?

    @EnvironmentObject var viewModel: NASAViewModel
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 30) {
                    switch viewModel.state {
                    case let .receivedData(model):
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
                            .fontWeight(.heavy)
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                            .animation(.easeInOut(duration: 1.0))
                            .foregroundColor(Color.black)
                            .font(.largeTitle)
                            .animation(.none)
                    }
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.top)

            .onAppear(perform: {
                viewModel.getData()
            })
        }
    }

    private func buildContent(model: NASAStuff) -> String {
        switch model {
        case let .error(e):
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
        vm.state = .none
        return vm
    }

    static var previews: some View {
        Group {
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")

            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPad Air (4th generation)"))
                .previewDisplayName("iPad Air (4th generation)")

            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                .previewDisplayName("iPhone XS Max")
        }.environmentObject(vm)
    }
}
