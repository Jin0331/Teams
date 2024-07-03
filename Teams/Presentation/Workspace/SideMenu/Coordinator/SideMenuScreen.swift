//
//  SideMenuScreen.swift
//  Teams
//
//  Created by JinwooLee on 7/3/24.
//

import ComposableArchitecture
import Foundation

@Reducer(state: .equatable)
enum SideMenuScreen {
    case sidemenu(SideMenuFeature)
    case workspaceAdd(WorkspaceAddFeature)
    case workspaceEdit(WorkspaceEditFeature)
}

