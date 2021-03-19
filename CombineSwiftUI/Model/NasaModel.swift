//
//  NasaModel.swift
//  CombineSwiftUI
//
//  Created by Kunal Kumar on 2021-01-17.
//

import Foundation
import SwiftUI

class NasaSampleAPI: Codable, Identifiable {
    var id = UUID()
    let date, explanation: String?
    let hdurl: String?
    let mediaType, serviceVersion, title: String?
    let url: String?
    var image: Image? {
        if let hdurl = url, let url = URL(string: hdurl) {
            return load(url: url)
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
