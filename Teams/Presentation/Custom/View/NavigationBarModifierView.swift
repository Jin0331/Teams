//
//  NavigationBarModifierView.swift
//  Teams
//
//  Created by JinwooLee on 6/11/24.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {

    var backgroundColor: UIColor?
    var titleColor: UIColor?
    var height : Double?
    

    init(backgroundColor: Color, titleColor: UIColor?) {
        self.backgroundColor = UIColor(backgroundColor)
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = UIColor(backgroundColor)
        coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = titleColor
    }

    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

struct CustomNavigationBarModifier: ViewModifier {
    var title: String
    var height: CGFloat

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .title1()
                    .foregroundColor(.brandBlack)
                Spacer()
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding()
            .background(.brandPrimary)
            .frame(height: height)

            content
        }
        .edgesIgnoringSafeArea(.top)
    }
}

extension View {

    func navigationBarColor(backgroundColor: Color, titleColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }
    
    func customNavigationBar(title: String, height: CGFloat) -> some View {
        self.modifier(CustomNavigationBarModifier(title: title, height: height))
    }
}

