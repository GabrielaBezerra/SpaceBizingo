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
        return "localhost"
        //getIPAddress()!
        //getGlobalIPAddress()!
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
            .bind(host: "localhost", port: serverPort)

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
    
    
//    func getIPAddress() -> String? {
//           var address: String?
//           var ifaddr: UnsafeMutablePointer<ifaddrs>?
//           if getifaddrs(&ifaddr) == 0 {
//               var ptr = ifaddr
//               while ptr != nil {
//                   defer { ptr = ptr?.pointee.ifa_next }
//                   let interface = ptr?.pointee
//                   let addrFamily = interface?.ifa_addr.pointee.sa_family
//                   if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6),
//                       let cString = interface?.ifa_name,
//                       String(cString: cString) == "en0",
//                       let saLen = (interface?.ifa_addr.pointee.sa_len) {
//                       var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//                       let ifaAddr = interface?.ifa_addr
//                       getnameinfo(ifaAddr,
//                                   socklen_t(saLen),
//                                   &hostname,
//                                   socklen_t(hostname.count),
//                                   nil,
//                                   socklen_t(0),
//                                   NI_NUMERICHOST)
//                       address = String(cString: hostname)
//                   }
//               }
//               freeifaddrs(ifaddr)
//           }
//           return address
//       }
//
//       func getGlobalIPAddress() -> String? {
//           do {
//               if let url = URL(string: "https://api.ipify.org") {
//                   let ipAddress = try String(contentsOf: url)
//                   print("My public IP address is: " + ipAddress)
//                   return ipAddress
//               }
//           } catch let error {
//               print(error)
//           }
//           return nil
//       }
    
}
