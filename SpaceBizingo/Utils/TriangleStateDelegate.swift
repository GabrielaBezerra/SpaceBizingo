//
//  TriangleStateDelegate.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 2/12/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation

protocol TriangleStateDelegate: class {
    func didSelect(index: Index)
    func didUnselect(index: Index)
    func didSetPiece(triangle: TriangleState)
    func didSetCaptain(triangle: TriangleState)
    func didDie(triangle: TriangleState)
}
