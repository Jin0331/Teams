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
                            Image(store.selectedTab == .dm ? .tabDMActive : .tabDMInactive)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("DM")
                                .bodyRegular()
                        }
                        .tag(WorkspaceTabCoordinator.Tab.dm)
                    
                    SearchCoordinatorView(store: store.scope(state: \.search, action: \.search))
                        .tabItem {
                            Image(store.selectedTab == .search ? .tabSearchActive : .tabSearchInactive)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("검색")
                                .bodyRegular()
                        }
                        .tag(WorkspaceTabCoordinator.Tab.search)
                    
                    ProfileCoordinatorView(store: store.scope(state: \.profile, action: \.profile))
                        .tabItem {
                            Image(store.selectedTab == .profile ? .tabProfileActive : .tabProfileInactive)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("설정")
                                .bodyRegular()
                        }
                        .tag(WorkspaceTabCoordinator.Tab.profile)
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
        case search
        case profile
    }
    
    enum Action {
        case home(HomeCoordinator.Action)
        case dm(DMCoordinator.Action)
        case search(SearchCoordinator.Action)
        case profile(ProfileCoordinator.Action)
        case tabSelected(Tab)
    }
    
    @ObservableState
    struct State : Equatable {
        //TODO: - current Workspace ID 초기화
        static let initialState = State(home: .initialState(),
                                        dm: .initialState(),
                                        search: .initialState(),
                                        profile: .initialState(tabViewMode: false),
                                        selectedTab: .home, sideMenu: .initialState())
        var home : HomeCoordinator.State
        var dm : DMCoordinator.State
        var search : SearchCoordinator.State
        var profile : ProfileCoordinator.State
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
        
        Scope(state: \.search, action: \.search) {
            SearchCoordinator()
        }
        
        Scope(state: \.profile, action: \.profile) {
            ProfileCoordinator()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .run { send in
                    await send(.home(.router(.routeAction(id: .home, action: .home(.timerOff)))))
                    await send(.dm(.router(.routeAction(id: .dmList, action: .dmList(.timerOff)))))
                    
                }
            
            case .home(.router(.routeAction(_, action: .home(.buttonTapped(.newMessageButtonTapped))))):
                state.selectedTab = .dm
                return .send(.home(.router(.routeAction(id: .home, action: .home(.timerOff)))))
                
            default:
                break
            }
            return .none
        }
    }
    
    
}

