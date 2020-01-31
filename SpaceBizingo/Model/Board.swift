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
            - reversed 
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
    
    var rowsNodes : [[SKShapeNode]] = []
    private var rowsData: [[TriangleData]] = []
    
    func triangleDatas(of type: TriangleType) -> [[TriangleData]] {
        return rowsData.compactMap { row in row.filter{ $0.type == type } }
    }
    
    private let scale: CGFloat
    private let originY: CGFloat
    
    init(amountOfRows x: Int, scale: CGFloat, originY: CGFloat, _ handler: ([SKShapeNode]) -> Void) {
        
        self.scale = scale
        self.originY = originY
        
        setup(numberOfRows: x)
        
        let nodes = rowsNodes.flatMap{ $0 }
        handler(nodes)
    }
    
    private func placePieces() {
        let playerTopTriangleDatas = triangleDatas(of: .pointTop)
        let playerBottomTriangleDatas = triangleDatas(of: .pointBottom)
        
        for i in 1...6 {
            playerTopTriangleDatas[5][i].setPiece()
        }
        
        for i in 1...7 {
            playerBottomTriangleDatas[7][i].setPiece()
        }
        
        for i in 1...7 {
            playerBottomTriangleDatas[7][i].setPiece()
        }
    }
    
    func setup(numberOfRows: Int) {
        
        let maxElementsInRow = (numberOfRows-1 * 2) + numberOfRows + 2
        
        var elementCounter = 3
        for row in 0...numberOfRows-1 {
            
            self.rowsNodes.append([])
            self.rowsData.append([])
            
            if elementCounter <= maxElementsInRow {
                elementCounter += 2
            }
            if (row == numberOfRows-2) {
                createRow(number: row, amountOfElements: elementCounter-2, backoff: row-1, beginsWithReversed: true)
            } else if (row == numberOfRows-1) {
                createRow(number: row, amountOfElements: elementCounter-4, backoff: row-3, beginsWithReversed: true)
            } else {
                createRow(number: row, amountOfElements: elementCounter, backoff: row)
            }
        }
    }
    
    func createRow(number i: Int, amountOfElements e: Int, backoff: Int, beginsWithReversed: Bool = false) {
        let xVar: Int = (e-backoff-3) * Int(-scale)
        for j in 0...e-1 {
            
            let condition: Bool = beginsWithReversed ? j % 2 == 0 : j % 2 != 0
            
            let triangleNode = SKShapeNode.triangle(reversed: condition,
                                                xoffset: CGFloat(j * Int(scale) + xVar),
                                                yoffset: CGFloat(i * Int(-scale) * 2),
                                                yOrigin: originY,
                                                scale: scale)
            
            let type: TriangleType = condition ? .pointBottom : .pointTop
            let triangleData = TriangleData(position: Index(x: i, y: j), type: type) {
                [weak triangleNode] color in
                triangleNode?.fillColor = color
            }
            
            self.rowsNodes[i].append(triangleNode)
            self.rowsData[i].append(triangleData)
        }
    }
    
    func getTriangle(atScreenPoint point: CGPoint) -> TriangleData? {
        for (indexRow, row) in rowsNodes.enumerated() {
            for (indexColumn, triangleNode) in row.enumerated() {
                let triangleData = rowsData[indexRow][indexColumn]
                if triangleNode.contains(point) { return triangleData }
            }
        }
        return nil
    }
    
}
