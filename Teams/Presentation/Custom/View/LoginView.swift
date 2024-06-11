//
//  LoginView.swift
//  Teams
//
//  Created by JinwooLee on 6/11/24.
//

import ComposableArchitecture
import SwiftUI

struct LoginView : View {
    
    var title : String
    var placement : String
    var text : Binding<String>
    var valid : Bool?
    var isPassword : Bool = false
    
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
            
            if isPassword {
                SecureField(placement, text: text)
                    .bodyRegular()
                    .padding()
                    .frame(width: 345, height: 44)
            } else {
                TextField(placement, text: text)
                    .bodyRegular()
                    .padding()
                    .frame(width: 345, height: 44)
            }
            
        }
    }
}
