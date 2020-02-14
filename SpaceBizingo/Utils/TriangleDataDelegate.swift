//
//  TriangleDataDelegate.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 2/12/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation

protocol TriangleDataDelegate: class {
    func didSelect(index: Index)
    func didUnselect(index: Index)
    func didSetPiece(triangle: TriangleData)
    func didSetCaptain(triangle: TriangleData)
    func didDie(triangle: TriangleData)
}
