//
//  SplashView.swift
//  Teams
//
//  Created by JinwooLee on 6/14/24.
//

import SwiftUI

struct SplashView : View {
    var body: some View {
        VStack {
            Text("Teams를 사용하면 어디서나")
                .title1()
                .frame(maxWidth: .infinity, alignment: .center)
            Text("팀을 모을 수 있습니다")
                .title1()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 150)
        
        
        Image(.onboarding)
            .frame(width: 368, height: 400)
        
        Spacer()
    }
}

#Preview {
    SplashView()
}
