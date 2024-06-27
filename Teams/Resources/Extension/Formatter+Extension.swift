//
//  Formatter+Extension.swift
//  CoinMarket
//
//  Created by JinwooLee on 3/17/24.
//

import Foundation

extension String {
    func toDate(dateFormat format : String) -> Date? { // "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 2024-05-20T02:40:47.476Z
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    
    func toDate() -> Date? { // "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 2024-05-20T02:40:47.476Z
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    
    func toDateRaw() -> Date? { // "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 2024-05-20T02:40:47.476Z
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    
    func formatDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: self) {
            _ = Date()
            let calendar = Calendar.current
            
            if calendar.isDateInToday(date) {
                dateFormatter.dateFormat = "HH:mm"
            } else {
                dateFormatter.dateFormat = "yy.MM.dd HH:mm"
            }
            
            return dateFormatter.string(from: date)
        }
        
        return ""
    }
}

extension Date {
    func toStringInChatList( dateFormat format: String) -> String {
        
        let current = Calendar.current
        let convertFormat = current.isDateInToday(self) ? format : "yy.MM.dd"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = convertFormat
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
    
    func toString( dateFormat format: String) -> String {
        
        let current = Calendar.current
        let convertFormat = current.isDateInToday(self) ? format : "yy.MM.dd"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = convertFormat
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
    
    func toStringRaw() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
    
}
