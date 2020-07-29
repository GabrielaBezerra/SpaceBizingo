//
//  GameServer.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 24/07/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import GRPC
import NIO
import Logging
import SwiftProtobuf

class GameServer {
    
    var ip: String {
        //"localhost"
        IPManager.localAddress!
        //IPManager.globalAddress!
    }
    
    var serverPort: Int = 0
    
    var provider: GameServerProvider? = nil
    
    var addressDescription: String {
        "\(self.ip):\(serverPort)"
    }
    
    func run(delegate: GameDelegate, handler: () -> Void) {
        // Create an event loop group for the server to run on.
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        defer {
            try! group.syncShutdownGracefully()
        }
        
        // Create a provider using the features we read.
        let provider = GameServerProvider(delegate: delegate)
        
        // Start the server and print its address once it has started.
        let server = Server.insecure(group: group)
            .withServiceProviders([provider])
            .bind(host: ip, port: serverPort)

        self.provider = provider
        
        server.map {
            $0.channel.localAddress
        }.whenSuccess { [weak self] address in
            DispatchQueue.main.async {
                self?.serverPort = address!.port!
            }
            print("🤖 server started on port \(address!.port!)")
        }
                //print("🤖 client just connected from port \(port)")
        
        handler()
        
        // Wait on the server's `onClose` future to stop the program from exiting.
        _ = try? server.flatMap { $0.onClose }.wait()
    }
    
}
