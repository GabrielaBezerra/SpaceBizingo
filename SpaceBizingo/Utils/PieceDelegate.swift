//
//  PieceDelegate.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 2/12/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation

protocol PieceDelegate: class {
    //func pieceDidMove(from originIndex: Index, to newIndex: Index)
    func pieceRemoved(from index: Index)
}
