//
//  GameServerProvider.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 24/07/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import GRPC
import NIO
import NIOConcurrencyHelpers

class GameServerProvider: GameProvider {

    weak var delegate: GameDelegate!
    
    init(delegate: GameDelegate) {
        self.delegate = delegate
    }
    
    let receiveMessage: (String, String, GameDelegate) -> () = { author, content, delegate in
            delegate.receivedMessage(author, msg: content)
    }
    
    func connectTo(request: ConnectionRequest, context: StatusOnlyCallContext) -> EventLoopFuture<ConnectionResult> {
        
        print("connectTo Request: \(request.ip):\(request.port)")
        
        let result = ConnectionResult.with {
            $0.success = true
            $0.description_p = "\(GRPCWrapper.shared.server.ip):\(GRPCWrapper.shared.server.serverPort)"
        }
        
        GRPCWrapper.shared.runClient(addressAndPort: "\(request.ip):\(request.port)", delegate: self.delegate, handler: { ip, port in
            DispatchQueue.main.async {
                self.delegate.youArePlayingAt("bottom")
                self.delegate.didStart()
            }
        })
        
        return context.eventLoop.makeSucceededFuture(result)
    }
    
    func sendMessage(request: ChatMessage, context: StatusOnlyCallContext) -> EventLoopFuture<ChatMessage> {
        
        print("sendMessage Request has been received: \(request.author): \(request.content)")
        
        receiveMessage(request.author, request.content, delegate)
        
        let replyMessage = ChatMessage.with {
            $0.author = request.author
            $0.content = request.content
        }
        
        return context.eventLoop.makeSucceededFuture(replyMessage)
    }

    func move(request: MoveRequest, context: StatusOnlyCallContext) -> EventLoopFuture<NextTurn> {
        
        print("move Request has been received: from (\(request.originIndex.row),\(request.originIndex.column)) to (\(request.newIndex.row),\(request.newIndex.column))")
        
        let originIndex = Index(
            row: Int(request.originIndex.row),
            column: Int(request.originIndex.column)
        )
        
        let newIndex = Index(
            row: Int(request.newIndex.row),
            column: Int(request.newIndex.column)
        )
        
        let nextTurnName = request.author.lowercased() == "top" ? "bottom" : "top"
        
        self.delegate.playerDidMove(request.author, from: originIndex, to: newIndex)
        self.delegate.newTurn(nextTurnName)
        
        let nextTurnMessage = NextTurn.with {
            $0.name = nextTurnName
        }
        
        return context.eventLoop.makeSucceededFuture(nextTurnMessage)
        
    }
    
    func gameOver(request: WinnerRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GameFinalResult> {
        
        let winner = request.name
        let loser = request.name.lowercased() == "top" ? "bottom" : "top"
        
        if winner.lowercased() == GRPCWrapper.player.rawValue.lowercased() {
            self.delegate.didWin()
        } else {
            self.delegate.didLose()
        }
        
        let gameFinalResult = GameFinalResult.with {
            $0.winner = winner
            $0.loser = loser
        }
        
        return context.eventLoop.makeSucceededFuture(gameFinalResult)
    }
    
    
}
