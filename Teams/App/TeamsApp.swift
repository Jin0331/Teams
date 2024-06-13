//
//  TeamsApp.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import ComposableArchitecture
import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

/*

 1. UserDefault에서 isLogin 값에 따라 분기처리
 2. 분기처리 값마다 store 설정해서 뿌리기
 
*/

@main
struct TeamsApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate : TeamsAppDelegate
    
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: APIKey.kakaoNativeAppKey.rawValue)
    }
    
    var body: some Scene {
        WindowGroup {
            OnboardingView(store: Store(initialState: OnboardingFeature.State(), reducer: {
                OnboardingFeature()
            }))
            .onOpenURL(perform: { url in
                            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                                _ = AuthController.handleOpenUrl(url: url)
                            }
                        })
        }
    }
}
