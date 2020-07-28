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
    
    func connectTo(request: ConnectionRequest, context: StatusOnlyCallContext) -> EventLoopFuture<ConnectionResult> {
        
        print("connectTo Request: \(request.ip):\(request.port)")
        
        let result = ConnectionResult.with {
            $0.success = true
            $0.description_p = "\(GRPCWrapper.shared.server.ip):\(GRPCWrapper.shared.server.serverPort)"
        }
        
        GRPCWrapper.shared.runner.run(addressAndPort: "\(request.ip):\(request.port)", delegate: self.delegate, handler: { ip, port in
            DispatchQueue.main.async {
                self.delegate.youArePlayingAt("bottom")
                self.delegate.didStart()
            }
        })
        
        return context.eventLoop.makeSucceededFuture(result)
    }
    
    func sendMessage(request: ChatMessage, context: StatusOnlyCallContext) -> EventLoopFuture<ChatMessage> {
        
        print("sendMessage Request: \(request.author): \(request.content)")
        
        let message = ChatMessage.with {
            $0.author = "Robin"
            $0.content = "Hello"
        }
        
        return context.eventLoop.makeSucceededFuture(message)
    }

}
