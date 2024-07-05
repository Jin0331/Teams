//
//  DM.swift
//  Teams
//
//  Created by JinwooLee on 7/5/24.
//

import Foundation

struct DM : Equatable, Identifiable {
    let roomID, createdAt : String
    let user : User
    
    var id : String { return roomID }
}

typealias DMList = [DM]
