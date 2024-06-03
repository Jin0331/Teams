//
//  LoginView.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import SwiftUI

// 코드 리팩토링은 추후. 기능 동작 확인부터 시작

struct LoginView: View {
    var body: some View {
        
        VStack(spacing : 20) {
            
            Button(action: {}, label: {
                HStack {
                    Image(.apple)
                    Text("Apple로 계속하기")
                }
            })
            .tint(.brandWhite)
            .frame(width: 323, height: 44)
            .title2()
            .background(.appleLogin)
            .cornerRadius(6)

            
            Button(action: {}, label: {
                HStack {
                    Image(.kakao)
                    Text("카카오톡으로 계속하기")
                }
            })
            .tint(.brandBlack)
            .frame(width: 323, height: 44)
            .title2()
            .background(.kakaoLogin)
            .cornerRadius(6)

            
            Button(action: {}, label: {
                HStack {
                    Image(.email)
                    Text("이메일로 시작하기")
                }
            })
            .tint(.brandWhite)
            .frame(width: 323, height: 44)
            .title2()
            .background(.brandGreen)
            .cornerRadius(6)
            
            HStack {
                Text("또는")
                Button("새롭게 회원가입 하기") {
                    
                }
                .tint(.brandGreen)
            }
            .title2()
        }
        
    }
}

#Preview {
    LoginView()
}
