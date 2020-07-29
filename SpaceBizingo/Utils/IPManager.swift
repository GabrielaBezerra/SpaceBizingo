//
//  IPManager.swift
//  SpaceBizingoTop
//
//  Created by Gabriela Bezerra on 29/07/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation

struct IPManager {
    
    static var localAddress: String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6),
                    let cString = interface?.ifa_name,
                    String(cString: cString) == "en0",
                    let saLen = (interface?.ifa_addr.pointee.sa_len) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let ifaAddr = interface?.ifa_addr
                    getnameinfo(ifaAddr,
                                socklen_t(saLen),
                                &hostname,
                                socklen_t(hostname.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }

    static var globalAddress: String? {
        do {
            if let url = URL(string: "https://api.ipify.org") {
                let ipAddress = try String(contentsOf: url)
                print("My public IP address is: " + ipAddress)
                return ipAddress
            }
        } catch let error {
            print(error)
        }
        return nil
    }
    
}
