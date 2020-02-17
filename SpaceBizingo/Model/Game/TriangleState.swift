//
//  TriangleState.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 30/01/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import UIKit

class TriangleState {
    
    weak var delegate: TriangleStateDelegate!
    let index: Index
    let type: Player
    let bgColor: UIColor!
    let pieceColor: UIColor!
    let captainColor: UIColor!
    
    private enum CodingKeys: String, CodingKey {
        case position
    }
    
    init(position: Index, type: Player, colorHandler: @escaping (UIColor) -> Void) {
        self.index = position
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
            if isEmpty {
                hasPiece = false
                hasCaptain = false
                isSelected = false
            }
        }
    }
    
    private(set) var isSelected: Bool = false {
        didSet {
            if isSelected { delegate.didSelect(index: self.index) }
            else { delegate.didUnselect(index: self.index) }
        }
    }
    
    private(set) var hasPiece: Bool = false {
        didSet {
            if hasPiece {
                isEmpty = false
                hasCaptain = false
            }
        }
    }
    
    private(set) var hasCaptain: Bool = false {
        didSet {
            if hasCaptain {
                isEmpty = false
                hasPiece = false
            }
        }
    }
    
    var setColorHandler: ((UIColor) -> Void)?
    
    func setPiece() {
        self.hasPiece = true
        //setColorHandler?(pieceColor)
        //delegate.didSetPiece(triangle: self)
    }
    
    func setCaptain() {
        self.hasCaptain = true
        setColorHandler?(captainColor)
        //delegate.didSetCaptain(triangle: self)
    }
    
    func setEmpty() {
        self.isEmpty = true
        setColorHandler?(bgColor)
    }
    
    func select() {
        self.isSelected = true
    }
    
    func deselect() {
        self.isSelected = false
    }
    
}


