//
//  GovUKDataDownloader.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 12/08/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

enum SessionError: Error {
    case badURL
    case noSession
    case noData
}

class GovUKDataDownloader {
    
    let url = URL (string: "https://api.coronavirus.data.gov.uk/v1/data")!
    
    func loadDataIntoController(regionCode: String?, callback: @escaping (Result<DataController, Error>) -> Void) {
        loadData { result in
            switch result {
            case .failure(let error): callback (.failure(error))
            case .success(let govUKData):
                guard let regionCode = regionCode else {
                    callback (.success(DataController (data: govUKData, regionCode: nil, regionalData: nil)))
                    return
                }
                self.loadRegionData(regionCode: regionCode) { result in
                    let regionalData: GovUKData?
                    switch result {
                    case .failure( _): regionalData = nil
                    case .success(let regData): regionalData = regData
                    }
                    callback (.success(DataController (data: govUKData, regionCode: regionCode, regionalData: regionalData)))
                }
            }
            
        }
    }
    
    private func loadData (callback: @escaping (Result<GovUKData,Error>)->Void) {
       
        let session = URLSession (configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 5
        session.configuration.timeoutIntervalForResource = 5
        
        let filters = "areaType=overview"
        let structure = """
        {"date":"date","newDeaths":"newDeaths28DaysByPublishDate","cumDeaths":"cumDeaths28DaysByPublishDate","newCases":"newCasesByPublishDate","cumCases":"cumCasesByPublishDate"}
        """
        //        {"date":"date","deaths":{"daily":"newDeaths28DaysByPublishDate","cumulative":"cumDeaths28DaysByPublishDate"},"cases":{"daily":"newCasesByPublishDate","cumulative":"cumCasesByPublishDate"}}

        let queryURL = url
            .appending("filters", value: filters)
            .appending("structure", value: structure)
//            .appending("latestBy", value: "newCasesBySpecimenDate")
        
        print (queryURL)
        session.dataTask(with: queryURL) {data, response, error in
            do {
                if let error = error { throw error }
                guard let data = data else { throw SessionError.noData }
                
                if let st = String (data: data, encoding: .utf8) {
                    print (st)
                }
            
                let decoder = JSONDecoder.createWithFixedISO8601DateDecoder()
                let govUKData = try decoder.decode(GovUKData.self, from: data)
                callback (.success(govUKData))
            } catch let e {
                print (e.localizedDescription)
                callback (.failure(e))
            }
        }.resume()
    }
    
    private func loadRegionData (regionCode: String, callback: @escaping (Result<GovUKData,Error>)->Void) {
        let session = URLSession (configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 5
        session.configuration.timeoutIntervalForResource = 5
        
        let filters = "areaType=utla;areaCode="+regionCode

        let structure = """
        {"date":"date","name":"areaName","newDeaths":"newDeaths28DaysByPublishDate","cumDeaths":"cumDeaths28DaysByPublishDate","newCases":"newCasesBySpecimenDate","cumCases":"cumCasesBySpecimenDate"}
        """
        
        let queryURL = url
            .appending("filters", value: filters)
            .appending("structure", value: structure)
        
        print (queryURL)
        session.dataTask(with: queryURL) {data, response, error in
            do {
                if let error = error { throw error }
                guard let data = data else { throw SessionError.noData }
                
                if let st = String (data: data, encoding: .utf8) {
                    print (st)
                }
                if data.count == 0 {
                }
                
                let decoder = JSONDecoder.createWithFixedISO8601DateDecoder()
                let govUKData = try decoder.decode(GovUKData.self, from: data)
                callback (.success(govUKData))
            } catch let e {
                print (e.localizedDescription)
                callback (.failure(e))
            }
        }.resume()
    }
    
    
}
