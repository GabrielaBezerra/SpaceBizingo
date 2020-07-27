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
    
    static let clientRunner = GameClientRunner()
    
    var client: GameClient!
        
    private init() { }
    
    func run(addressAndPort: String) {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
          try? group.syncShutdownGracefully()
        }

        let ip = "localhost"//"\(addressAndPort.split(separator: ":")[0])"
        let port = Int(addressAndPort)!//Int(addressAndPort.split(separator: ":")[1])!
        
        let channel = ClientConnection.insecure(group: group)
          .connect(host: ip, port: port)
        
        self.client = GameClient(channel: channel)
        
        print("🤖 client started with challenge \(ip):\(port)")
        
        let message = ChatMessage.with {
            $0.author = "Batman"
            $0.content = "Greetings."
        }
        
        let result = GameClientRunner.clientRunner.client.sendMessage(message)
        do {
            let response = try result.response.wait()
            print("sendMessage response \(response.author): \(response.content)")
        } catch {
            print("Failed waiting for sendMessage response: \(error)")
        }
        
        RunLoop.main.run(until: .distantFuture)
        
    }
    
}



//* [Common] _BSMachError: port 7d17; (os/kern) invalid capability (*) "Unable to insert COPY_SEND"

//* notice io.grpc.client_channel : error=connectTimeout(NIO.TimeAmount(nanoseconds: 20000000000)) connection_id=* connection attempt failed

//* notice io.grpc.client_channel : error=NIOConnectionError(host: "*", port: *, dnsAError: nil, dnsAAAAError: nil, connectionErrors: [NIO.SingleConnectionFailure(target: [IPv6]*, error: connection reset (error set): Connection refused (errno: 61)), NIO.SingleConnectionFailure(target: [IPv4]*, error: connection reset (error set): Connection refused (errno: 61))]) connection_id=* connection attempt failed
