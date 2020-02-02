//
//  Message.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 2/2/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation

struct Message: Codable {
    let timestamp: String
    let author: String
    let content: String
}
