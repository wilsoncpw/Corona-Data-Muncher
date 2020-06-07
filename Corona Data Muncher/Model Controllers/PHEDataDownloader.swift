//
//  PHEDataDownloader.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 05/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

enum SessionError: Error {
    case badURL
    case noSession
    case noData
}

class PHEDataDownloader {
    
    let casesURL : URL
    let deathsURL : URL
    
    init () {
        let baseURL : URL! = URL(string: "https://coronavirus.data.gov.uk/downloads/json/")

        casesURL = baseURL.appendingPathComponent("coronavirus-cases_latest.json")
        deathsURL = baseURL.appendingPathComponent("coronavirus-deaths_latest.json")
    }
    
    func loadDataIntoController (callback: @escaping (Result<DataController,Error>) ->Void)  {
        
        loadDeaths { result in
            do {
                switch result {
                case .failure(let error): throw error
                case .success(let deaths):
                    self.loadCases { result in
                        do {
                            switch result {
                            case .failure(let error): throw error
                            case .success(let cases): callback (.success(DataController (deaths: deaths, cases: cases)))
                            }
                            
                        } catch let e {
                            callback (.failure(e))
                        }
                    }
                }
            } catch let e {
                callback (.failure(e))
            }
        }
    }
    
    private func loadDeaths (callback: @escaping (Result<Deaths,Error>)->Void) {
        let session = URLSession (configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 5
        session.configuration.timeoutIntervalForResource = 5
        
        
        session.dataTask(with: deathsURL) {data, response, error in
            do {
                if let error = error { throw error }
                guard let data = data else { throw SessionError.noData }
                let decoder = JSONDecoder.createWithFixedISO8601DateDecoder()
                let deaths = try decoder.decode(Deaths.self, from: data)
                callback (.success(deaths))
            } catch let e {
                print (e.localizedDescription)
                callback (.failure(e))
            }
        }.resume()
    }
    
    private func loadCases (callback: @escaping (Result<Cases,Error>)->Void) {
        let session = URLSession (configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 5
        session.configuration.timeoutIntervalForResource = 5
        
        session.dataTask(with: casesURL) {data, response, error in
            do {
                if let error = error { throw error }
                guard let data = data else { throw SessionError.noData }
                let decoder = JSONDecoder.createWithFixedISO8601DateDecoder()
                let cases = try decoder.decode(Cases.self, from: data)
                callback (.success(cases))
            } catch let e {
                print (e.localizedDescription)
                callback (.failure(e))
            }
        }.resume()
    }
    

}
