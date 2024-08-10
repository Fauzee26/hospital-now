//
//  HospitalModel.swift
//  ExamHospitalNow
//
//  Created by HilmyF on 09/08/24.
//

import Foundation

struct Hospital: Codable {
    let name: String
    let address: String
    let region: String
    let phone: String?
    let province: String
}

func getProvincesArray(from hospitals: [Hospital]) -> [String] {
    let provinces = hospitals.map { $0.province }
    return Array(Set(provinces))
}
