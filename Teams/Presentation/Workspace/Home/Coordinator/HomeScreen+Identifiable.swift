//
//  HomeScreen+Identifiable.swift
//  Teams
//
//  Created by JinwooLee on 7/6/24.
//

extension HomeScreen.State: Identifiable {
  var id: ID {
    switch self {
    case .home:
            .home
    case .channelAdd:
            .channelAdd
    }
  }

  enum ID: Identifiable {
    case home
    case channelAdd
    var id: ID { self }
  }
}
