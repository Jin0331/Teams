//
//  WorkspaceTabCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/20/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct WorkspaceTabCoordinatorView : View {
    @Perception.Bindable var store : StoreOf<WorkspaceTabCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                HomeCoordinatorView(store: store.scope(state: \.home, action: \.home))
                    .tabItem {
                        Image(.homeTab)
                        Text("홈")
                            .bodyRegular()
                    }
                    .tag(WorkspaceTabCoordinator.Tab.home)
            }
            .accentColor(Color.brandBlack)
        }
    }
}

@Reducer
struct WorkspaceTabCoordinator {
    enum Tab : Hashable {
        case home
    }
    
    enum Action {
        case home(HomeCoordinator.Action)
        case tabSelected(Tab)
    }
    
    @ObservableState
    struct State : Equatable {
        //TODO: - current Workspace ID 초기화
        static let initialState = State(home: .initialState(), selectedTab: .home, sideMenu: .initialState())
        
        var home : HomeCoordinator.State
        var selectedTab: Tab
        var sideMenu : SideMenuCoordinator.State
        var sidemenuOpen : Bool = false
    }
    
    var body : some ReducerOf<Self> {
        
        Scope(state : \.home, action: \.home) {
            HomeCoordinator()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                
            default:
                break
            }
            return .none
        }
    }
    
    
}

