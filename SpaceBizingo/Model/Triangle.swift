//
//  Triangle.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 1/30/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import SpriteKit

extension SKShapeNode {
    
    static func triangle(reversed: Bool = false,
                         multiplier: CGFloat = 1.0,
                         xoffset: CGFloat = 0.0,
                         yoffset: CGFloat = 0.0,
                         yOrigin: CGFloat,
                         scale: CGFloat) -> SKShapeNode {
        
        let path = UIBezierPath()
        
        if reversed {
            
            path.move(to: CGPoint(x: -scale * multiplier + xoffset,
                                  y: yOrigin+scale * multiplier + yoffset))
            path.addLine(to: CGPoint(x: scale * multiplier + xoffset,
                                     y: yOrigin+scale * multiplier + yoffset))
            path.addLine(to: CGPoint(x: 0.0 * multiplier + xoffset,
                                     y: yOrigin-scale * multiplier + yoffset))
            path.addLine(to: CGPoint(x: -scale * multiplier + xoffset,
                                     y: yOrigin+scale * multiplier + yoffset))
            
        } else {
            
            path.move(to: CGPoint(x: 0.0 * multiplier + xoffset,
                                  y: yOrigin+scale * multiplier + yoffset))
            path.addLine(to: CGPoint(x: -scale * multiplier + xoffset,
                                     y: yOrigin-scale * multiplier + yoffset))
            path.addLine(to: CGPoint(x: scale * multiplier + xoffset,
                                     y: yOrigin-scale * multiplier + yoffset))
            path.addLine(to: CGPoint(x: 0.0 * multiplier + xoffset,
                                     y: yOrigin+scale * multiplier + yoffset))
            
        }
        
        let triangle = self.init(path: path.cgPath)
        triangle.lineWidth = 0
        triangle.fillColor = reversed ? .systemIndigo : .white
        
        return triangle
        
    }
    
}
