////
////  MainTabCoordinator.swift
////  Teams
////
////  Created by JinwooLee on 6/14/24.
////
//
//import ComposableArchitecture
//import SwiftUI
//import TCACoordinators
//
//struct MainTabCoordinatorView : View {
//    @Perception.Bindable var store : StoreOf<MainTabCoordinator>
//    
//    var body : some View {
//        WithPerceptionTracking {
//            
//        }
//    }
//}
//
//
//@Reducer
//struct MainTabCoordinator {
//    
//    enum Tab : Hashable {
//        case home
//    }
//    
//    enum Action {
//        case home(HomeFeature)
//        case tabSelected(Tab)
//    }
//    
//    @ObservableState
//    struct State :Equatable {
//        static let initialState = State(
//          home: .initialState,
//          selectedTab: .app
//        )
//
//    }
//    
//    
//}
