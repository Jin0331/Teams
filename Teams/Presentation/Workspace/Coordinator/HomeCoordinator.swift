////
////  HomeCoordinator.swift
////  Teams
////
////  Created by JinwooLee on 6/14/24.
////
//
//import ComposableArchitecture
//import SwiftUI
//import TCACoordinators
//
//@Reducer(state: .equatable)
//enum HomeScreen {
//    case home(HomeFeature)
//}
//
//@Reducer
//struct HomeCoordinator {
//    @ObservableState
//    struct State : Equatable {
//        static let initialState = HomeCoordinator.State(
//            routes: [.root(.home(.init()), embedInNavigationView: true)]
//        )
//        var routes: IdentifiedArrayOf<Route<HomeScreen.State>>
//    }
//    
//    enum Action {
//        case router(IndexedRouterActionOf<HomeScreen>)
//    }
//    
//    var body : some Reducer<State, Action> {
//        Reduce { state, action in
//            switch action {
//            }
//        }
//    }
//}
