//
//  TriangleData.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 30/01/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import UIKit

class TriangleData {
    
    let position: Index
    let type: TriangleType
    let bgColor: UIColor!
    let pieceColor: UIColor!
    let captainColor: UIColor!
    
    init(position: Index, type: TriangleType, colorHandler: @escaping (UIColor) -> Void) {
        self.position = position
        self.type = type
        self.setColorHandler = colorHandler
        
        if type == .pointBottom {
            self.bgColor = Colors.trianglePointDown.color
            self.pieceColor = Colors.playerBottom.color
            self.captainColor = Colors.playerBottomCaptain.color
        } else {
            self.bgColor = Colors.trianglePointUp.color
            self.pieceColor = Colors.playerTop.color
            self.captainColor = Colors.playerTopCaptain.color
        }
    }
    
    private(set) var isEmpty: Bool = true {
        didSet {
            if hasPiece {
                hasPiece = false
                hasCaptain = false
            }
        }
    }
    
    private(set) var hasPiece: Bool = false {
        didSet {
            if isEmpty {
                isEmpty = false
                hasCaptain = false
            }
        }
    }
    
    private(set) var hasCaptain: Bool = false {
        didSet {
            if isEmpty {
                isEmpty = false
                hasPiece = false
            }
        }
    }
    
    var setColorHandler: ((UIColor) -> Void)?
    
    func setPiece() {
        self.hasPiece = true
        setColorHandler?(pieceColor)
    }
    
    func setCaptain() {
          self.hasCaptain = true
          setColorHandler?(captainColor)
    }
    
    func setEmpty() {
        self.isEmpty = true
        setColorHandler?(bgColor)
    }
    
    func highlight() {
        setColorHandler?(Colors.highlight.color)
    }
}


