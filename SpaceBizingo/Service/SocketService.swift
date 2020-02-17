//
//  ChatService.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 2/2/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import SocketIO

protocol GameDelegate: class {
    func didStart()

    func newTurn(_ name: String)
    func playerDidMove(_ name: String, from originIndex: Index, to newIndex: Index)

    func didWin()
    func didLose()
    
    func receivedMessage(_ name: String, msg: String)
    
    func youArePlayingAt(_ team: String)
}


class SocketService {
    
    let manager: SocketManager
    let socket: SocketIOClient
    var name: String?
    
    weak var delegate: GameDelegate! {
        didSet {
            self.start()
        }
    }
 
    init() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:8900")!, config: [.log(true), .compress])
        socket = manager.defaultSocket
    }
    
    private func start() {
        configSocket()
        socket.connect()
    }
    
    func move(from originIndex: Index, to newIndex: Index) {
        self.socket.emit("playerMove", originIndex.row, originIndex.column, newIndex.row, newIndex.column)
    }
    
    func sendMessage(author: String, content: String) {
        self.socket.emit("chatMessage", content, author)
    }
    
    func configSocket() {
        
        socket.on("name") { [weak self] data, ack in
            if let name = data[0] as? String {
                self?.name = name
                self?.delegate?.youArePlayingAt(name)
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            self?.name = ""
            self?.delegate?.youArePlayingAt("")
        }
        
        socket.on("startGame") { [weak self] data, ack in
            self?.delegate.didStart()
            return
        }

        socket.on("chatMessage") { [weak self] data, ack in
            if let msg = data[0] as? String, let name = data[1] as? String {
                self?.delegate.receivedMessage(name, msg: msg)
            }
        }
        
        socket.on("playerMove") { [weak self] data, ack in
            if let name = data[0] as? String, let originX = data[1] as? Int, let originY = data[2] as? Int, let newX = data[3] as? Int, let newY = data[4] as? Int {
                self?.delegate.playerDidMove(name, from: Index(row: originX, column: originY), to: Index(row: newX, column: newY))
            }
        }
        
        socket.on("win") { [weak self] data, ack in
            self?.delegate.didWin()
        }
        
        socket.on("lose") { [weak self] data, ack in
            self?.delegate.didLose()
        }
        
        socket.on("currentTurn") { [weak self] data, ack in
            if let name = data[0] as? String {
                self?.delegate.newTurn(name)
            }
        }
        
        socket.on("gameOver") {data, ack in
            exit(0)
        }
        
        socket.onAny {
            print("Got event: \($0.event), with items: \($0.items!)")
        }
    }
}
