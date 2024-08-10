//
//  NetworkManager.swift
//  ExamHospitalNow
//
//  Created by HilmyF on 09/08/24.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchHospitals(completion: @escaping (Result<[Hospital], Error>) -> Void) {
        let urlString = "https://dekontaminasi.com/api/id/covid19/hospitals"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let countries = try JSONDecoder().decode([Hospital].self, from: data)
                    completion(.success(countries))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
