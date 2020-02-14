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
    case highlightStroke
    
    case trianglePointUp
    case trianglePointDown
    
    case playerTop
    case playerBottom
    
    case playerTopCaptain
    case playerBottomCaptain
    
    var color: UIColor {
        get {
            switch self {
            case .trianglePointUp: return UIColor(red: 81/255, green: 177/255, blue: 119/255, alpha: 1)
            case .trianglePointDown: return UIColor(red: 209/255, green: 238/255, blue: 219/255, alpha: 1)
            case .playerBottom: return .systemPink
            case .playerTop: return .black
            case .playerTopCaptain: return UIColor(red: 117/255, green: 45/255, blue: 213/255, alpha: 1)
            case .playerBottomCaptain: return .yellow
            case .highlight: return UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.5)
            case .highlightStroke: return UIColor.green
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

enum GameResult {
    case topWin
    case bottomWin
    case draw
}
