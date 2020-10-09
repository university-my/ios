//
//  Record+NetworkClient.swift
//  My University
//
//  Created by Yura Voevodin on 12/8/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import Foundation

extension Record {
    
    class NetworkClient {
        
        // MARK: - Properties
        
        private let cacheFile: URL
        private var completionHandler: ((_ error: Error?) -> ())?
        
        // MARK: - Initialization
        
        init(cacheFile: URL) {
            self.cacheFile = cacheFile
        }
        
        // MARK: - Download Records with Group ID
        
        func downloadRecords(groupID: Int64, date: Date, universityURL: String, _ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            let dateString = DateFormatter.short.string(from: date)
            let urlString = "\(URL.myUniversityAPI.absoluteString)/universities/\(universityURL)/groups/\(groupID)/records?pair_date=\(dateString)"
            guard let url = URL(string: urlString) else {
                completionHandler?(nil)
                return
            }
            let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
                
                if let error = error {
                    self.completionHandler?(error)
                } else {
                    self.downloadFinished(url: url, response: response)
                }
            }
            task.resume()
        }
        
        // MARK: - Download Records with Auditorium ID
        
        func downloadRecords(auditoriumID: Int64, date: Date, universityURL: String, _ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            let dateString = DateFormatter.short.string(from: date)
            let urlString = "\(URL.myUniversityAPI.absoluteString)/universities/\(universityURL)/auditoriums/\(auditoriumID)/records?pair_date=\(dateString)"
            guard let url = URL(string: urlString) else {
                completionHandler?(nil)
                return
            }
            let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
                
                if let error = error {
                    self.completionHandler?(error)
                } else {
                    self.downloadFinished(url: url, response: response)
                }
            }
            task.resume()
        }
        
        // MARK: - Download Records with Teacher ID
        
        func downloadRecords(teacherID: Int64, date: Date, universityURL: String, _ completion: @escaping ((_ error: Error?) -> ())) {
            completionHandler = completion
            
            let dateString = DateFormatter.short.string(from: date)
            let urlString = "\(URL.myUniversityAPI.absoluteString)/universities/\(universityURL)/teachers/\(teacherID)/records?pair_date=\(dateString)"
            guard let url = URL(string: urlString) else {
                completionHandler?(nil)
                return
            }
            let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
                if let error = error {
                    self.completionHandler?(error)
                } else {
                    self.downloadFinished(url: url, response: response)
                }
            }
            task.resume()
        }
        
        // MARK: - Helpers
        
        private func downloadFinished(url: URL?, response: URLResponse?) {
            if let localURL = url {
                do {
                    /*
                     If we already have a file at this location, just delete it.
                     Also, swallow the error, because we don't really care about it.
                     */
                    try FileManager.default.removeItem(at: cacheFile)
                } catch {
                    
                }
                do {
                    try FileManager.default.moveItem(at: localURL, to: cacheFile)
                    completionHandler?(nil)
                } catch {
                    completionHandler?(error)
                }
            } else {
                completionHandler?(nil)
            }
        }

        // MARK: - Tests

        static func loadTestRecords(_ completion: @escaping (([Record.CodingData]) -> Void)) {
            let urlString = "\(URL.myUniversityAPI.absoluteString)/records/test"
            guard let url = URL(string: urlString) else { return }

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    let records = serializeTestRecords(from: data)
                    completion(records)
                } else {
                    completion([])
                }
            }
            task.resume()
        }

        private static func serializeTestRecords(from data: Data) -> [Record.CodingData] {
            // Date formatter
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            // Serialization
            do {
                let object = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let records = object?.first { key, _ in
                    return key == "records"
                }
                if let records = records?.value as? [[String: Any]] {
                    let parsedRecords = records.compactMap { Record.CodingData($0, dateFormatter: dateFormatter) }
                    return parsedRecords
                } else {
                    return []
                }
            } catch {
                return []
            }
        }
    }
}
