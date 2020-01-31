//
//  Triangle.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 1/30/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

let reversedColor: UIColor = .systemIndigo

extension SKShapeNode {
    
    var reversed: Bool {
        get {
            return (self.fillColor.description == UIColor(cgColor: reversedColor.cgColor).description)

        }
    }
    
    static func triangle(reversed: Bool = false,
                         multiplier: CGFloat = 1.0,
                         xoffset: CGFloat = 0.0,
                         yoffset: CGFloat = 0.0,
                         yOrigin: CGFloat,
                         scale: CGFloat) -> SKShapeNode {
        
        let fillColor: UIColor = reversed ? reversedColor : .systemTeal
        
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
        triangle.fillColor = fillColor
        
        return triangle
        
    }
    
}
