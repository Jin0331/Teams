//
//  View+Extension.swift
//  Teams
//
//  Created by JinwooLee on 6/4/24.
//

import SwiftUI

extension View {
    func backgroundForIsActive(_ active: Bool) -> some View {
        if active {
            return Color.brandGreen
        } else {
            return Color.brandInActive
        }
    }
    
    func ifLet<ContentView: View, Value>(_ opt: Optional<Value>, transform: (Self, Value) -> ContentView) -> some View {
  
        if let opt {
            transform(self, opt) as! Self // 값이 있다면 ForgroundStyle넣어주기
        } else {
            self // 없다면 그냥 자기 자신 반환하기
        }
    }
}

extension View {
    func asButton(action: @escaping () -> Void ) -> some View {
        modifier(ButtonWrapper(action: action))
    }
}

struct ButtonWrapper: ViewModifier {
    
    let action: () -> Void
    
    func body(content: Content) -> some View {
        Button(
            action:action,
            label: { content }
        )
    }
}
