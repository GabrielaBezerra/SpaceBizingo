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

struct Triangle {
    let node: SKShapeNode
    let data: TriangleData
}

class Board {
    
    private(set) var node: SKNode = SKNode()
    private var rowsNodes : [[SKShapeNode]] = []
    private var rowsData: [[TriangleData]] = []
    private var pieces: [Piece] = []
    
    func triangleDatas(of type: TriangleType) -> [[TriangleData]] {
        return rowsData.compactMap { row in row.filter{ $0.type == type } }
    }
    
    func getTriangle(at index: Index) -> Triangle? {
        if index.row >= 0, index.column >= 0, index.row < rowsNodes.count, index.column < rowsNodes[index.row].count {
            return Triangle(node: rowsNodes[index.row][index.column], data: rowsData[index.row][index.column])
        }
        return nil
    }
    
    private let scale: CGFloat
    private let originY: CGFloat
    
    init(amountOfRows x: Int, scale: CGFloat, originY: CGFloat) {
        
        self.scale = scale
        self.originY = originY
        
        setup(numberOfRows: x)
        
        rowsNodes.flatMap{ $0 }.forEach { self.node.addChild($0) }
        
        placePieces()
    }
    
    private func placePieces() {
        let playerTopTriangleDatas = triangleDatas(of: .pointTop)
        let playerBottomTriangleDatas = triangleDatas(of: .pointBottom)
        
        //pieces
        for i in 1...3 {
            placePiece(at: playerTopTriangleDatas[2][i])
            playerTopTriangleDatas[2][i].setPiece();
        }
        for i in 1...4 {
            placePiece(at: playerTopTriangleDatas[3][i])
            playerTopTriangleDatas[3][i].setPiece()
        }
        for i in 1...5 {
            placePiece(at: playerTopTriangleDatas[4][i])
            playerTopTriangleDatas[4][i].setPiece()
        }
        for i in 1...6 {
            placePiece(at: playerTopTriangleDatas[5][i])
            playerTopTriangleDatas[5][i].setPiece()
        }
        
        for i in 1...7 {
            placePiece(at: playerBottomTriangleDatas[7][i])
            playerBottomTriangleDatas[7][i].setPiece()
        }
        for i in 2...7 {
            placePiece(at: playerBottomTriangleDatas[8][i])
            playerBottomTriangleDatas[8][i].setPiece()
        }
        for i in 3...7 {
            placePiece(at: playerBottomTriangleDatas[9][i])
            playerBottomTriangleDatas[9][i].setPiece()
        }
        
        //captains
        placePiece(at: playerTopTriangleDatas[5][2], captain: true)
        placePiece(at: playerTopTriangleDatas[5][5], captain: true)
        
        placePiece(at: playerBottomTriangleDatas[7][2], captain: true)
        placePiece(at: playerBottomTriangleDatas[7][6], captain: true)
    }
    
    private func placePiece(at triangle: TriangleData, captain: Bool = false) {
        
        triangle.setPiece()
        
        var color =  triangle.type == .pointBottom ? Colors.playerBottom.color : Colors.playerTop.color
        if captain {
            color = triangle.type == .pointBottom ? Colors.playerBottomCaptain.color : Colors.playerTopCaptain.color
        }
        
        let offsetY: CGFloat = triangle.type == .pointBottom ? 13 : -10
        if let tnode = getTriangle(at: triangle.index)?.node {
            let center = CGPoint(x: tnode.path!.boundingBox.midX, y: tnode.path!.boundingBox.midY + offsetY)
            let piece = Piece(color: color, position: center, captain: captain, index: triangle.index)
            
            self.pieces.append(piece)
            self.node.addChild(piece.node)
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
            let triangleData = TriangleData(position: Index(row: i, column: j), type: type) {
                [weak triangleNode] color in
                triangleNode?.fillColor = color
            }
            triangleData.delegate = self
            
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
    
    func getPiece(at index: Index) -> Piece? {
        return pieces.filter { $0.index == index }.first
    }
    
    func turnOnMasks(for moves: [Triangle?], at piece: Piece) {
        moves.forEach {
            if let tile = $0 {
                if tile.data.isEmpty {
                    createMoveMask(triangle: tile)
                    piece.possibleMoves.append(tile.data.index)
                }
            }
        }
    }
    
    func createMoveMask(triangle: Triangle) {
        let mask = triangle.node.copy() as! SKShapeNode
        mask.lineWidth = 5
        mask.strokeColor = Colors.highlightStroke.color
        mask.fillColor = Colors.highlight.color
        self.node.addChild(mask)
    }
}

extension Board: TriangleDataDelegate {
    
    func didSetPiece(triangle: TriangleData) {
        
    }
    
    func didSetCaptain(triangle: TriangleData) {
        
    }
    
    func didDie(triangle: TriangleData) {
        
    }
    
    func didSelect(index: Index) {
        
        node.children.forEach {
            if ($0 as! SKShapeNode).fillColor.description == Colors.highlight.color.description {
                $0.removeFromParent()
            }
        }
        
        guard let triangle: Triangle = getTriangle(at: index) else { return }
        guard let piece = getPiece(at: index) else { return }
        
        let moves: [Triangle?] = [
            getTriangle(at: Index(row: index.row, column: index.column + 2)),       //left
            getTriangle(at: Index(row: index.row + 1, column: index.column + 2)),   //bottom left
            getTriangle(at: Index(row: index.row + 1, column: index.column)),       //bottom right
            getTriangle(at: Index(row: index.row, column: index.column - 2)),       //right
            getTriangle(at: Index(row: index.row - 1, column: index.column - 2)),   //top left
            getTriangle(at: Index(row: index.row - 1, column: index.column))        //top right
        ]
        
        let movesFor2LastRow: [Triangle?] = [
            getTriangle(at: Index(row: index.row, column: index.column + 2)),       //left
            getTriangle(at: Index(row: index.row + 1, column: index.column - 2)),   //bottom left
            getTriangle(at: Index(row: index.row + 1, column: index.column)),       //bottom right
            getTriangle(at: Index(row: index.row, column: index.column - 2)),       //right
            getTriangle(at: Index(row: index.row - 1, column: index.column - 1)),   //top right
            getTriangle(at: Index(row: index.row - 1, column: index.column + 1))    //top left
        ]
        
        let movesFor3LastRow: [Triangle?] = [
            getTriangle(at: Index(row: index.row, column: index.column + 2)),       //left
            getTriangle(at: Index(row: index.row + 1, column: index.column + 1)),   //bottom left
            getTriangle(at: Index(row: index.row + 1, column: index.column - 1)),   //bottom right
            getTriangle(at: Index(row: index.row, column: index.column - 2)),       //right
            getTriangle(at: Index(row: index.row - 1, column: index.column - 2)),   //top right
            getTriangle(at: Index(row: index.row - 1, column: index.column))        //top left
        ]
        
        let movesForLastRow: [Triangle?] = [
            getTriangle(at: Index(row: index.row, column: index.column + 2)),       //left
            getTriangle(at: Index(row: index.row, column: index.column - 2)),       //right
            getTriangle(at: Index(row: index.row - 1, column: index.column)),       //top right
            getTriangle(at: Index(row: index.row - 1, column: index.column + 2))    //top left
        ]
        
        if !triangle.data.isEmpty {
            
            let selectedMask = triangle.node.copy() as! SKShapeNode
            selectedMask.lineWidth = 5
            selectedMask.strokeColor = Colors.highlightStroke.color
            selectedMask.fillColor = Colors.highlight.color
            self.node.addChild(selectedMask)
            
            if triangle.data.index.row < rowsNodes.count - 3 {
                
                turnOnMasks(for: moves, at: piece)
                
            } else if triangle.data.index.row == rowsNodes.count - 3 {
                
                turnOnMasks(for: movesFor3LastRow, at: piece)
                
            } else if triangle.data.index.row == rowsNodes.count - 2 {
                
                turnOnMasks(for: movesFor2LastRow, at: piece)
                
            } else if triangle.data.index.row == rowsNodes.count - 1 {
                
                turnOnMasks(for: movesForLastRow, at: piece)
                
            }
            
        }
        
        
        
    }
    
    func didUnselect(index: Index) {
        node.children.forEach {
            if ($0 as! SKShapeNode).fillColor == Colors.highlight.color {
                $0.removeFromParent()
            }
        }
    }
    
}
