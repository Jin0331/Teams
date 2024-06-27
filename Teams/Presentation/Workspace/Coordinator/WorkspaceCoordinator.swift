//
//  WorkspaceCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/17/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct WorkspaceCoordinatorView : View {
    @State var store : StoreOf<WorkspaceCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment:.leading) {
                VStack {
                    if !store.workspaceList.isEmpty {
                        WorkspaceTabCoordinatorView(store: store.scope(state: \.tab, action: \.tab))
                    } else {
                        HomeEmptyCoordinatorView(store: store.scope(state: \.homeEmpty, action: \.homeEmpty))
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                }
                .zIndex(1)
                
                if store.sidemenuOpen {
                    SideMenuCoordinatorView(store: store.scope(state: \.sideMenu, action: \.sideMenu))
                        .frame(width: 317)
                        .transition(.move(edge: .leading))
                        .zIndex(3)
                    Color.brandBlack
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .zIndex(2)
                        .onTapGesture {
                            store.send(.closeSideMenu)
                        }
                }
            }
            .statusBar(hidden: store.sidemenuOpen)
            .animation(.default, value: store.sidemenuOpen)
//            .onAppear {
//                store.send(.onAppear)
//            }
        }
    }
    
}

@Reducer
struct WorkspaceCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(tab: .initialState ,homeEmpty: .initialState, sideMenu: .initialState, workspaceList : [], workspaceCount: 0)
        var tab : WorkspaceTabCoordinator.State
        var homeEmpty : HomeEmptyCoordinator.State
        var sideMenu : SideMenuCoordinator.State
        var workspaceList : [Workspace] = []
        var workspaceCount : Int = 0
        var sidemenuOpen : Bool = false
        
    }
    
    enum Action {
        case tab(WorkspaceTabCoordinator.Action)
        case homeEmpty(HomeEmptyCoordinator.Action)
        case sideMenu(SideMenuCoordinator.Action)
        case onAppear
        case myWorkspaceResponse(Result<[Workspace], APIError>)
        case closeSideMenu
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some ReducerOf<Self> {
        
        Scope(state : \.tab, action: \.tab) {
            WorkspaceTabCoordinator()
        }
        
        Scope(state : \.homeEmpty, action: \.homeEmpty) {
            HomeEmptyCoordinator()
        }
        
        Scope(state : \.sideMenu, action : \.sideMenu) {
            SideMenuCoordinator()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
                
            //TODO: - Workspace count API 호출
            case .onAppear:
                print("Workspace Coordinator 뿅 🌟🌟🌟🌟🌟🌟🌟🌟🌟")
                return .run { send in
                    await send(.myWorkspaceResponse(
                        networkManager.getWorkspaceList()
                    ))
                }
            
            case let .myWorkspaceResponse(.success(response)):
                print(response, "🌟 success")
                state.workspaceCount = response.count
                
            case let .myWorkspaceResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                
                print(errorType)
                
                return .none
            
            case .closeSideMenu:
                state.sidemenuOpen = false
                
            case .homeEmpty(.router(.routeAction(_, action: .workspaceAdd(.createWorkspaceComplete)))), .sideMenu(.router(.routeAction(_, action: .workspaceAdd(.createWorkspaceComplete)))):
                print("workspace add compete 🌟🌟🌟🌟")
                state.workspaceCount += 1
            
            case .homeEmpty(.router(.routeAction(_, action: .emptyView(.openSideMenu)))), .tab(.home(.router(.routeAction(_, action: .home(.openSideMenu))))):
                state.sidemenuOpen = true
            
            case .homeEmpty(.router(.routeAction(_, action: .emptyView(.closeSideMenu)))), .tab(.home(.router(.routeAction(_, action: .home(.closeSideMenu))))):
                state.sidemenuOpen = false
            
            default :
                break
            }
            return .none
        }
    }
}
