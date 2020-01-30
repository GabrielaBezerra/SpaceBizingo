//
//  TriangleData.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 30/01/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation

class TriangleData: Codable {
    
    let position: Index

    let reversed: Bool
    
    init(position: Index, reversed: Bool) {
        self.position = position
        self.reversed = reversed
    }
    
    private(set) var isEmpty: Bool = true {
        didSet {
            if isEmpty {
                hasBlue = false
                hasRed = false
            }
        }
    }
    
    private(set) var hasRed: Bool = false {
        didSet {
            if hasRed {
                hasBlue = false
                isEmpty = false
            }
        }
    }
    
    private(set) var hasBlue: Bool = false {
        didSet {
            if hasBlue {
                hasRed = false
                isEmpty = false
            }
        }
    }
    
    func setBlue() {
        self.hasBlue = true
    }
    
    func setRed() {
        self.hasRed = true
    }
    
    func setEmpty() {
        self.isEmpty = true
    }
    
    func highlight(at position: Index, handler: (Index) -> Void) {
        handler(position)
    }
}


