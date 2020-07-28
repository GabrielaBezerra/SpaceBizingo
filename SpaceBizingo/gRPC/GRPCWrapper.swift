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
    
    public func run(delegate: GameDelegate, handler: @escaping (Int) -> ()) {
//        guard !server.isRunning else {
//            handler(server.port!)
//            return
//        }
//        server.onRun = handler
        DispatchQueue.global().async {
            self.server.run(delegate: delegate, handler: { })
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
}
