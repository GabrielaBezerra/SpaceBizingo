//
//  Piece.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 2/2/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import SpriteKit

class Piece {
    
    var node: SKShapeNode
    var isCaptain: Bool
    var index: Index
    var possibleMoves: [Index] = []
    
    init(color: UIColor, position: CGPoint, captain: Bool = false, index: Index) {
        
        self.index = index
        self.isCaptain = captain
        
        let piece = SKShapeNode(circleOfRadius: 15)
        piece.fillColor = color
        piece.lineWidth = 0
        piece.zPosition = 3
        piece.position = position
        
        let shadow = SKShapeNode(circleOfRadius: 15)
        shadow.fillColor = UIColor(white: 0.1, alpha: 0.2)
        shadow.lineWidth = 0
        shadow.zPosition = 2
        shadow.position = CGPoint(x: position.x - 3, y: position.y - 5)
        
        let node = SKShapeNode()
        node.addChild(shadow)
        node.addChild(piece)
        
        self.node = node
    }
    
}
