//
//  OnboardingView.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack {
            Text("새싹톡을 사용하면 어디서나")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("팀을 모을 수 있습니다")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Image("")
        }
    }
}

#Preview {
    OnboardingView()
}
