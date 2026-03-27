//
//  Department.swift
//  LinphoneApp
//
//  Created by hvn-dyan on 25/3/26.
//

import Foundation

struct Department: Codable, Identifiable {
    let compCd: String?
    let compNm: String?
    let deptCd: String
    let deptNm: String
    let totalContact: Int
    let children: [Department]?
    
    var id: String { deptCd }
}
