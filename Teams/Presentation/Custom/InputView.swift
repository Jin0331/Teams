//
//  InputView.swift
//  Teams
//
//  Created by JinwooLee on 6/5/24.
//

import SwiftUI

struct InputView: View {
    
    var title : String
    var placement : String
    var text : Binding<String>
    var valid : Bool?
    var isEmail : Bool = false
    var isPassword : Bool = false
    var isPasswordRepeat : Bool = false
    var isNumber : Bool = false
    var emailValid : Bool = false
    
    var focusState : FocusState<SignUpFeature.State.Field?>.Binding
    
    var body: some View {
        VStack(alignment : .leading, spacing: 10) {
            
            if let valid {
                Text(title)
                    .title2()
                    .foregroundStyle(valid ? .brandBlack : .brandError)
            } else {
                Text(title)
                    .title2()
                    .foregroundStyle(.brandBlack)
            }
            
            HStack(spacing : 5) {
                
                if isEmail {
                    TextField(placement, text: text)
                        .bodyRegular()
                        .padding()
                        .frame(width: 233, height: 44)
                        .focused(focusState, equals: .email)
                    
                    Button("중복 확인") {
                        
                    }
                    .frame(width: 100, height: 44)
                    .title2()
                    .foregroundStyle(.brandWhite)
                    .background(backgroundForIsActive(emailValid))
                    .cornerRadius(8)
                    .disabled(!emailValid)
                } else {
                    if isPassword {
                        SecureField(placement, text: text)
                            .bodyRegular()
                            .padding()
                            .frame(width: 345, height: 44)
                            .focused(focusState, equals: .password)
                    } else if isPasswordRepeat {
                        SecureField(placement, text: text)
                            .bodyRegular()
                            .padding()
                            .frame(width: 345, height: 44)
                            .focused(focusState, equals: .passwordRepeat)
                    } else if isNumber {
                        TextField(placement, text: text)
                            .bodyRegular()
                            .padding()
                            .frame(width: 345, height: 44)
                            .keyboardType(.decimalPad)
                            .focused(focusState, equals: .phoneNumber)
                    } else {
                        TextField(placement, text: text)
                            .bodyRegular()
                            .padding()
                            .frame(width: 345, height: 44)
                            .focused(focusState, equals: .nickname)
                    }
                    

                }
            }
        }
        .frame(width: 345, height: 76)
    }
}
