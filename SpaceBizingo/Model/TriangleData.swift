//
//  TriangleData.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 30/01/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import UIKit

protocol TriangleDataDelegate: class {
    func didSelect(index: Index)
    func didUnselect(index: Index)
    func didSetPiece(triangle: TriangleData)
    func didSetCaptain(triangle: TriangleData)
    func didDie(triangle: TriangleData)
}

class TriangleData {
    
    weak var delegate: TriangleDataDelegate!
    let position: Index
    let type: TriangleType
    let bgColor: UIColor!
    let pieceColor: UIColor!
    let captainColor: UIColor!
    
    private enum CodingKeys: String, CodingKey {
        case position
    }
    
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
    
    private(set) var isSelected: Bool = false {
        didSet {
            if isSelected { delegate.didSelect(index: self.position) }
            else { delegate.didSelect(index: self.position) }
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
        //setColorHandler?(pieceColor)
        delegate.didSetPiece(triangle: self)
    }
    
    func setCaptain() {
        self.hasCaptain = true
        setColorHandler?(captainColor)
        delegate.didSetCaptain(triangle: self)
    }
    
    func setEmpty() {
        self.isEmpty = true
        setColorHandler?(bgColor)
    }
    
    func select() {
        self.isSelected = true
    }
    
}


