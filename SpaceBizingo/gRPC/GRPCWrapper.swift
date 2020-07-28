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
        
        let sendMessageRequest = GRPCWrapper.shared.runner.client.sendMessage(messageToSend)
        
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
}
