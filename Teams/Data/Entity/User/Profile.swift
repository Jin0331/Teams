//
//  Profile.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import Foundation

/*
 let userID, email, nickname, profileImage, phone, provider, createdAt : String
 let sesacCoin : Int
 */

struct Profile : Equatable, Identifiable {
    let userID, email, nickname, profileImage, phone, provider, createdAt : String
    let sesacCoin : Int
    
    var id : String { return userID }
}

extension Profile {
    var createdAtToString : String {
        return createdAt.toDateRaw()!.toString(dateFormat: "yy.MM.dd")
    }
    
    var createdAtDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: createdAt)
    }
    
    var profileImageToUrl : URL {
        
        if !profileImage.isEmpty {
            return URL(string: APIKey.baseURLWithVersion() + profileImage)!
        } else {
            return URL(string: APIKey.defaultProfileImage())!
        }
    }
}
