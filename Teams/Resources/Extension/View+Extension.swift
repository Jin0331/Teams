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
}

