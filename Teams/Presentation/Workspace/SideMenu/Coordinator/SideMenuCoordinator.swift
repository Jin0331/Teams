//
//  SideMenuCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/24/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators
import Kingfisher

@Reducer(state: .equatable)
enum SideMenuScreen {
    case sidemenu(SideMenuFeature)
    case workspaceAdd(WorkspaceAddFeature)
    case workspaceEdit(WorkspaceEditFeature)
}

struct SideMenuCoordinatorView : View {
    let store : StoreOf<SideMenuCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .sidemenu(store):
                SideMenuView(store: store)
            case let .workspaceAdd(store):
                WorkspaceAddView(store: store)
            case let .workspaceEdit(store):
                WorkspaceEditView(store:store)
            }
        }
    }
}

@Reducer
struct SideMenuCoordinator {
    @ObservableState
    struct State : Equatable {
        
        static func initialState(workspaceIdCurrent: String = "") -> Self {
            Self(
                routes: [.root(.sidemenu(.init(workspaceIdCurrent: workspaceIdCurrent)))]
            )
        }
        
        var routes : [Route<SideMenuScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<SideMenuScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                
            case .router(.routeAction(_, action: .sidemenu(.createWorkspaceTapped))):
                state.routes.presentSheet(.workspaceAdd(.init()))
                
            case let .router(.routeAction(_, action: .sidemenu(.workspaceEdit(workspace)))):
                state.routes.presentSheet(.workspaceEdit(.init(workspaceID: workspace.id, workspaceImage: workspace.profileImageToUrl, workspaceName: workspace.name, workspaceDescription: workspace.description)))
                
            case .router(.routeAction(_, action: .workspaceAdd(.dismiss))), .router(.routeAction(_, action: .workspaceEdit(.dismiss))):
                state.routes.dismiss()
            
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
    
}
