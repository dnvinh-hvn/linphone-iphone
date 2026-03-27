//
//  DeptUserItem.swift
//  LinphoneApp
//
//  Created by hvn-dyan on 26/3/26.
//

import Foundation
struct DeptUserItem: Codable, Identifiable {
    let userId: String
    let userNm: String
    let compCd: String?
    let compNm: String?
    let deptCd: String
    let deptNm: String?
    let gradeCd: String?
    let gradeNm: String?
    let email: String?
    let officeTel: String?
    let officeFax: String?
    let officeAddr: String?
    let mobile: String?
    let duty: String?
    let userSt: String?
    let inputDt: String?
    let updateDt: String?
    
    var id: String { userId }
}
