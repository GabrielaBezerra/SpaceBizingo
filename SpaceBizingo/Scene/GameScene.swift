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
    private var player: Player!
    
    private let socketService: SocketService = SocketService()
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        //Setup Board
        self.board = Board(amountOfRows: 11, scale: 33, originY: 333)
        self.addChild(board.node)
        
        //Setup Socket Connection
        socketService.delegate = self
    }
    
    func touchDown(atPoint point: CGPoint) {
        
        //get triangle at touch point
        guard let touchedTriangleData = board.getTriangle(atScreenPoint: point) else { return }

        //verify if there is any piece selected
        if let selectedTriangle = board.getSelectedTriangle(),
           let pieceAtSelectedTriangle = board.getPiece(at: selectedTriangle.data.index) {
        
            //verify if touch was in possibleMoves
            if pieceAtSelectedTriangle.possibleMoves.contains(touchedTriangleData.index) {
                board.movePiece(from: pieceAtSelectedTriangle.index, to: touchedTriangleData.index)
            } else {
                selectedTriangle.data.deselect()
            }
        
        } else {
            // No selected triangle, select it!
            if touchedTriangleData.hasPiece {
                touchedTriangleData.select()
            }
        }
        
    }
    
    func touchUp(atPoint point: CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//    }
    
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


extension GameScene: GameDelegate {
    
    func youArePlayingAt(_ team: String) {
        self.player = Player(rawValue: team)
        print("👾 You are player \(self.player.rawValue)")
    }
    
    func didStart() {
        
    }
    
    func newTurn(_ name: String) {
        
    }
    
    func playerDidMove(_ name: String, from originIndex: Index, to newIndex: Index) {
        
    }
    
    func didWin(_ name: String) {
        
    }
    
    func receivedMessage(_ name: String, msg: String) {
        print("\(name):",msg)
    }
    
}
