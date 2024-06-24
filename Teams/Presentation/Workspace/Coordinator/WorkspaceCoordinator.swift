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
                    if store.workspaceCount > 0 {
                        Text("hihi")
                    } else {
                        HomeEmptyCoordinatorView(store: store.scope(state: \.homeEmpty, action: \.homeEmpty))
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                }
                .zIndex(1)
                
                if store.sidemenuOpen {
                    SideMenuView()
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
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
}

@Reducer
struct WorkspaceCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(homeEmpty: .initialState, workspaceCount: 0)
        var homeEmpty : HomeEmptyCoordinator.State
        var workspaceCount : Int
        var sidemenuOpen : Bool = false
        
    }
    
    enum Action {
        case homeEmpty(HomeEmptyCoordinator.Action)
        case onAppear
        case myWorkspaceResponse(Result<[Workspace], APIError>)
        case closeSideMenu
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some ReducerOf<Self> {
        Scope(state : \.homeEmpty, action: \.homeEmpty) {
            HomeEmptyCoordinator()
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
                
            case .homeEmpty(.router(.routeAction(_, action: .workspaceAdd(.createWorkspaceComplete)))):
                print("workspace add compete 🌟🌟🌟🌟")
                state.workspaceCount += 1
            
            case .homeEmpty(.router(.routeAction(_, action: .emptyView(.openSideMenu)))):
                state.sidemenuOpen = true
            
            case .homeEmpty(.router(.routeAction(_, action: .emptyView(.closeSideMenu)))):
                state.sidemenuOpen = false
                
            default :
                break
            }
            return .none
        }
    }
}
