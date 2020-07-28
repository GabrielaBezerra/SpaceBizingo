//
//  GameClient.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 24/07/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import GRPC
import NIO

class GameClientRunner {
    
    var client: GameClient!
    
    weak var delegate: GameDelegate!
    
    func run(addressAndPort: String, delegate: GameDelegate, handler: @escaping (String,Int) -> Void) {
             
        self.delegate = delegate
        
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//        defer {
//          try? group.syncShutdownGracefully()
//        }

        let ip = "\(addressAndPort.split(separator: ":")[0])"
        let port = Int(addressAndPort.split(separator: ":")[1])!
        
        let channel = ClientConnection.insecure(group: group)
          .connect(host: ip, port: port)
        
        self.client = GameClient(channel: channel)
        
        print("🤖 client started with address \(ip):\(port)")
        
        handler(GRPCWrapper.shared.server.ip, GRPCWrapper.shared.server.serverPort)
        
        RunLoop.main.run(until: .distantFuture)
        
    }
    
}
