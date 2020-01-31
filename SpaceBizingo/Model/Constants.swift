//
//  GameConstants.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 1/31/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import UIKit

enum Colors {
    
    case highlight
    
    case trianglePointUp
    case trianglePointDown
    
    case playerTop
    case playerBottom
    
    case playerTopCaptain
    case playerBottomCaptain
    
    var color: UIColor {
        get {
            switch self {
            case .trianglePointUp: return .lightGray
            case .trianglePointDown: return .gray
            case .playerBottom: return .systemPink
            case .playerTop: return .green
            case .playerTopCaptain: return .white
            case .playerBottomCaptain: return .black
            case .highlight: return UIColor(red: 0.5, green: 0.5, blue: 0.9, alpha: 0.5)
            }
        }
    }
}

enum TriangleType {
    case pointTop
    case pointBottom
}

enum Player {
    case playerTop
    case playerBottom
}
