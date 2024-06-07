//
//  ToastView.swift
//  Teams
//
//  Created by JinwooLee on 6/7/24.
//

import SwiftUI

struct ToastView: View {
    
    var text : String
    
    var body: some View {
        
        ZStack {
            Text(text)
                .frame(width: 243, height: 36)
                .bodyRegular()
                .foregroundColor(.brandWhite)
                .background(.brandGreen)
                .cornerRadius(7)
                .padding()
                .offset(x:0, y:250)
            
        }
    }
}

#Preview {
    ToastView(text: "hihi")
}
