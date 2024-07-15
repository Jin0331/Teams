//
//  Font.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import SwiftUI

extension View {
    func title1() -> some View {
        self.font(.system(size: 22).weight(.bold))
    }
    
    func title2() -> some View {
        self.font(.system(size: 16).weight(.bold))
    }
    
    func bodyBold() -> some View {
        self.font(.system(size: 13).weight(.bold))
    }
    
    func bodyRegular() -> some View {
        self.font(.system(size: 13).weight(.regular))
    }
    
    func captionRegular() -> some View {
        self.font(.system(size: 12).weight(.regular))
    }

}
