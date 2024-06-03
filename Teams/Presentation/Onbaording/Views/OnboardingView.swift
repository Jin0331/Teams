//
//  OnboardingView.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {
    
    
    var body: some View {
        VStack {
            
            VStack {
                Text("새싹톡을 사용하면 어디서나")
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
            
            Button("시작하기") {
                
            }
            .tint(.brandWhite)
            .frame(width: 345, height: 44)
            .title2()
            .background(.brandGreen)
            .cornerRadius(8)
            .padding()
        }
    }
}

#Preview {
    OnboardingView()
}
