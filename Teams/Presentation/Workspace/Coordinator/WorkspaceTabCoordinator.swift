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
                            Image(store.selectedTab == .home ? .tabhomeActive : .tabhomeInactive)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("홈")
                                .bodyRegular()
                        }
                        .tag(WorkspaceTabCoordinator.Tab.home)
                    
                    DMCoordinatorView(store: store.scope(state: \.dm, action: \.dm))
                        .tabItem {
                            Image(store.selectedTab == .dm ? .tabdmActive : .tabdmInactive)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("DM")
                                .bodyRegular()
                        }
                        .tag(WorkspaceTabCoordinator.Tab.dm)
                }
                .accentColor(Color.brandBlack)
        }
    }
}

@Reducer
struct WorkspaceTabCoordinator {
    enum Tab : Hashable {
        case home
        case dm
    }
    
    enum Action {
        case home(HomeCoordinator.Action)
        case dm(DMCoordinator.Action)
        case tabSelected(Tab)
    }
    
    @ObservableState
    struct State : Equatable {
        //TODO: - current Workspace ID 초기화
        static let initialState = State(home: .initialState(), dm: .initialState(), selectedTab: .home, sideMenu: .initialState())
        
        var home : HomeCoordinator.State
        var dm : DMCoordinator.State
        var selectedTab: Tab
        var sideMenu : SideMenuCoordinator.State
        var sidemenuOpen : Bool = false
    }
    
    var body : some ReducerOf<Self> {
        
        Scope(state : \.home, action: \.home) {
            HomeCoordinator()
        }
        
        Scope(state : \.dm, action: \.dm) {
            DMCoordinator()
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

