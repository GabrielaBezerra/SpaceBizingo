//
//  GRPCWrapper.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 27/07/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation

class GRPCWrapper {
    
    static var shared = GRPCWrapper()
    
    static var player: Player = .disconnected
    
    var runner = GameClientRunner()
    var server = GameServer()
    
    private init() {}
    
    func runServer(delegate: GameDelegate, handler: @escaping (Int) -> ()) {
        DispatchQueue.global().async {
            self.server.run(delegate: delegate, handler: { })
        }
    }
    
    func runClient(addressAndPort: String, delegate: GameDelegate, handler: @escaping (String, Int) -> Void) {
        DispatchQueue.global().async {
            self.runner.run(addressAndPort: addressAndPort, delegate: delegate, handler: handler)
        }
    }
    
    func connectTo(ip: String, port: Int, handler: (Bool?,String?) -> Void) {
        let connectionRequest = ConnectionRequest.with {
            $0.ip = GRPCWrapper.shared.server.ip
            $0.port = Int32(GRPCWrapper.shared.server.serverPort)
        }
        
        let connectionRequestResult = GRPCWrapper.shared.runner.client.connectTo(connectionRequest)
        
        do {
            let result = try connectionRequestResult.response.wait()
            print("connectTo response description: \(result.description_p) and success: \(result.success)")
            handler(result.success, result.description_p)
        } catch {
            print("Failed waiting for connectTo response: \(error)")
            handler(nil,nil)
        }
    }
    
    func sendMessage(author: String, content: String, handler: (String?, String?) -> Void) {
        let messageToSend = ChatMessage.with {
            $0.author = author
            $0.content = content
        }
        
        let sendMessageRequest = self.runner.client.sendMessage(messageToSend)
        
        do {
            let result = try sendMessageRequest.response.wait()
            print("sendMessage response has been received - \(result.author): \(result.content)")
            handler(result.author, result.content)
        } catch {
            print("Failed waiting for sendMessage response: \(error)")
            handler(nil,nil)
        }
    }
    
    func receiveMessage(author: String, content: String, handler: @escaping (String, String) -> Void) {
        handler(author, content)
    }
    
    func endTurnAndMove(author: String, from originIndex: Index, to newIndex: Index, handler: (String?) -> Void) {
        
        let moveRequest = MoveRequest.with { move in
            let origin = MoveRequest.IndexRequest.with { index in
                index.row = Int32(originIndex.row)
                index.column = Int32(originIndex.column)
            }
            
            let new = MoveRequest.IndexRequest.with { index in
                index.row = Int32(newIndex.row)
                index.column = Int32(newIndex.column)
            }
            
            move.originIndex = origin
            move.newIndex = new
            move.author = author
        }
        
        let request = self.runner.client.move(moveRequest)
        
        do {
            let result = try request.response.wait()
            print("endTurnAndMove response has been received - new turn \(result.name)")
            handler(result.name)
        } catch {
            print("Failed waiting for endTurnAndMove response: \(error)")
            handler(nil)
        }
        
    }
    
    func gameOver(winner: String, handler: (String?) -> Void) {
        
        let winnerRequest = WinnerRequest.with {
            $0.name = winner
        }
        
        let request = self.runner.client.gameOver(winnerRequest)
        
        do {
            let result = try request.response.wait()
            print("gameOver response has been received - result winner: \(result.winner) loser: \(result.loser)")
            handler(result.winner)
        } catch {
            print("Failed waiting for endTurnAndMove response: \(error)")
            handler(nil)
        }
    }
}
