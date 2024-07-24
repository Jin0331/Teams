//
//  SearchScreen+Identifiable.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import Foundation

extension SearchScreen.State : Identifiable {
    var id : ID {
        switch self {
        case .search:
                .search
        }
    }
    
    enum ID :Identifiable {
        case search
        
        var id: ID { self }
    }
}
