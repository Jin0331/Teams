//
//  MainCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/15/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct MainCoordinatorView : View {
    @State var store : StoreOf<MainCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.isLogined {
                    if store.isSignUp { // 회원가입시
                        HomeInitialCoordinatorView(store: store.scope(state: \.homeInitial, action: \.homeInitial))
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else {
                        WorkspaceCoordinatorView(store: store.scope(state: \.workspace, action: \.workspace))
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                } else {
                    OnboardingCoordinatorView(store: store.scope(state: \.onboarding, action: \.onboarding))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .onAppear {
                store.send(.onApper)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetLogin)) { notification in
            store.send(.refreshTokenExposed)
        }
    }
}

@Reducer
struct MainCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(onboarding: .initialState, homeInitial: .initialState(), workspace: .initialState, isLogined: UserDefaultManager.shared.isLogined, isSignUp: false)
        var onboarding : OnboardingCoordinator.State
        var homeInitial : HomeInitialCoordinator.State
        var workspace : WorkspaceCoordinator.State
        var isLogined : Bool
        var isSignUp : Bool
    }
    
    enum Action {
        case onApper
        case onboarding(OnboardingCoordinator.Action)
        case homeInitial(HomeInitialCoordinator.Action)
        case workspace(WorkspaceCoordinator.Action)
        case refreshTokenExposed
        case autoLogin(Result<[Workspace], APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utilitiesFunction
    
    var body : some ReducerOf<Self> {
        
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingCoordinator()
        }
        Scope(state: \.homeInitial, action: \.homeInitial) {
            HomeInitialCoordinator()
        }
        Scope(state: \.workspace, action: \.workspace) {
            WorkspaceCoordinator()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            
            //MARK: - 자동로그인에서 사용되는 부분
            case .onApper:
                if UserDefaultManager.shared.isLogined {
                    return .run { send in
                        await send(.autoLogin(
                            networkManager.getWorkspaceList()
                        ))}
                } else {
                    return .none
                }
            
            //TODO: - 초기에 initalState로 초기화되었다가, 비동기 action으로 state가 초기화되면서 ,땅->땅 으로 뷰가 전환됨. Progress View 필요할듯
            //MARK: - Workspace가 지정되는 부분
            case let .autoLogin(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType)
                
                
            case let .onboarding(.router(.routeAction(_, action: .emailLogin(.loginComplete(response))))), let .autoLogin(.success(response)):
                if let mostRecentWorkspace = utilitiesFunction.getMostRecentWorkspace(from: response) {
                    state.workspace = .init(tab: .init(home: .initialState(workspaceCurrent: mostRecentWorkspace), 
                                                       dm: .initialState(currentWorkspace: mostRecentWorkspace),
                                                       selectedTab: .home, 
                                                       sideMenu: .initialState()),
                                            homeEmpty: .initialState, sideMenu: .initialState(),
                                            workspaceCurrent: mostRecentWorkspace,
                                            showingView: response.count > 0 ? .home : .empty)
                }
                state.isLogined = true
                state.isSignUp = false
                
            case let .onboarding(.router(.routeAction(_, action: .signUp(.signUpComplete(nickname))))):
                state.isLogined = true
                state.isSignUp = true
                state.homeInitial = .initialState(nickname: nickname)
                
            case .onboarding(.router(.routeAction(_, action: .auth(.loginComplete)))):
                state.isLogined = true
                state.isSignUp = false
                
            case .homeInitial(.router(.routeAction(_, action: .initial(.dismiss)))):
                state.isLogined = true
                state.isSignUp = false
                
            case .refreshTokenExposed:
                state.isLogined = false
                state.isSignUp = false
                
            default:
              break
            }
            return .none
        }
    }
}
