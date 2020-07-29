//
//  ChatService.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 2/2/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation

protocol GameDelegate: class {
    func didStart()

    func newTurn(_ name: String)
    func playerDidMove(_ name: String, from originIndex: Index, to newIndex: Index)

    func didWin()
    func didLose()
    
    func receivedMessage(_ name: String, msg: String)
    
    func youArePlayingAt(_ team: String)
}
