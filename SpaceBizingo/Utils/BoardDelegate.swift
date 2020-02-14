//
//  BoardDelegate.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 2/12/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation

protocol BoardDelegate {
    func killPiecesIfNeeded()
    func movePieceIfNeeded(from originIndex: Index, to newIndex: Index)
    func gameDidOver(result: GameResult)
}
