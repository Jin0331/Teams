//
//  SideMenuScreen+Identifiable.swift
//  Teams
//
//  Created by JinwooLee on 7/3/24.
//

extension SideMenuScreen.State: Identifiable {
  var id: ID {
    switch self {
    case .sidemenu:
            .sidemenu
    case .workspaceAdd:
            .workspaceAdd
    case .workspaceEdit:
            .workspaceEdit
    }
  }

  enum ID: Identifiable {
    case sidemenu
    case workspaceAdd
    case workspaceEdit

    var id: ID { self }
  }
}

