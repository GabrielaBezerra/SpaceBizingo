//
//  GameScene.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 1/29/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//
import UIKit
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0

    private var board: Board!
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        setupBoard()
    }
    
    private func setupBoard() {
        
        self.board = Board(amountOfRows: 11, scale: 33, yOrigin: 333)
        
        board.rowsNodes.forEach { row in
            row.forEach { triangle in
                self.addChild(triangle)
            }
        }
        
        board.rowsData.first?.first?.setRed()
    }
    
    private func paintTriangle(at points: [CGPoint], mutualExclusive: Bool = true) {
        points.forEach { point in
            board.rowsNodes.enumerated().forEach { indexRow, row in
                row.enumerated().forEach { indexColumn, triangle in
                    if triangle.contains(point) {
                        triangle.fillColor = .red
                    } else if mutualExclusive {
                        let reversed: Bool = board.rowsData[indexRow][indexColumn].reversed
                        triangle.fillColor = reversed ? .systemIndigo : .systemTeal
                    }
                }
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        paintTriangle(at: touches.compactMap { $0.location(in: self) })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
