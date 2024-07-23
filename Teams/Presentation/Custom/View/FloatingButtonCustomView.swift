//
//  FloatingButtonCustomView.swift
//  Teams
//
//  Created by JinwooLee on 7/23/24.
//

import SwiftUI

struct HomeFloatingButton: View {
    
    var body: some View {
        ZStack {
            Image(.newMessage)
                .resizable()
                .frame(width: 54, height: 54)
                .shadow(color: Color(hex: "f7b731").opacity(0.3), radius: 15, x: 0, y: 15)
        }
    }
}

struct IconAndTextButton: View {

    var imageName: String
    var buttonText: String
    let imageWidth: CGFloat = 22

    var body: some View {
        ZStack {
            Color.white
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .foregroundColor(Color(hex: "778ca3"))
                    .frame(width: imageWidth, height: imageWidth)
                    .clipped()
                Spacer()
                Text(buttonText)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(Color(hex: "4b6584"))
                Spacer()
            }
            .padding(.horizontal, 15)
        }
        .frame(width: 160, height: 45)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "F4F4F4"), lineWidth: 1)
        )
    }
}
