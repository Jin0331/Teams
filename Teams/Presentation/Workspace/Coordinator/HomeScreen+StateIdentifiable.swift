//
//  HomeScreen+StateIdentifiable.swift
//  Teams
//
//  Created by JinwooLee on 6/14/24.
//

import Foundation

extension HomeScreen.State: Identifiable {
  var id: UUID {
    switch self {
    case let .home(state):
      state.id
    }
  }
}
