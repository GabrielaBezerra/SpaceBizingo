//
//  Board.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 1/30/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import SpriteKit

//MARK: Refactor: build structs for:
/*
        - Row
 
        - Triangle
            - position (x,y)
            - isEmpty -> Bool
            - hasRed -> Bool
            - hasBlue -> Bool
 
        - Piece
            - moveTo(1,2,3,4,5,6) -> Bool
            - hasDied() -> Bool
 
        - Kernel
            - 5x3
            - pivot
            - pivotIsDead() -> Bool
            - availableMoves() -> [1,2,3,4,5,6]
            - How to deal with borders?
 */

class Board {
    
    var rows : [[SKShapeNode]] = []
    
    private let scale: CGFloat
    private let yOrigin: CGFloat
    
    init(amountOfRows x: Int, scale: CGFloat, yOrigin: CGFloat) {
        
        self.scale = scale
        self.yOrigin = yOrigin
        
        drawBoard(numberOfRows: x)
    }
    
    func drawBoard(numberOfRows: Int) {
        let maxElementsInRow = (numberOfRows-1 * 2) + numberOfRows + 2
        var elementCounter = 3
        for row in 0...numberOfRows-1 {
            
            self.rows.append([])
            
            if elementCounter <= maxElementsInRow {
                elementCounter += 2
            }
            if (row == numberOfRows-2) {
                drawRow(number: row, amountOfElements: elementCounter-2, backoff: row-1, beginsWithReversed: true)
            } else if (row == numberOfRows-1) {
                drawRow(number: row, amountOfElements: elementCounter-4, backoff: row-3, beginsWithReversed: true)
            } else {
                drawRow(number: row, amountOfElements: elementCounter, backoff: row)
            }
        }
    }
    
    func drawRow(number i: Int, amountOfElements e: Int, backoff: Int, beginsWithReversed reversed: Bool = false) {
        let xVar: Int = (e-backoff-3) * Int(-scale)
        for j in 0...e-1 {
            let condition: Bool = reversed ? j % 2 == 0 : j % 2 != 0
            let triangle = SKShapeNode.triangle(reversed: condition,
                                                xoffset: CGFloat(j * Int(scale) + xVar),
                                                yoffset: CGFloat(i * Int(-scale) * 2),
                                                yOrigin: yOrigin,
                                                scale: scale)
            
            self.rows[i].append(triangle)
        }
    }
    
}
