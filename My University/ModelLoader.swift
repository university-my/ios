//
//  ModelLoader.swift
//  My University
//
//  https://www.swiftbysundell.com/articles/creating-generic-networking-apis-in-swift/
//

import Foundation
import Combine

//struct ModelLoader<Model: Identifiable & Decodable> {
//    var urlSession = URLSession.shared
//    var urlResolver: (Model.ID) -> URL
//
//    func loadModel(withID id: Model.ID) -> AnyPublisher<Model, Error> {
//        urlSession.publisher(for: urlResolver(id))
//    }
//}
