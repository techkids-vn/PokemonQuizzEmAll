//
//  CircleMask.swift
//  PokemonQuizEmAll
//
//  Created by AVAVT on 8/6/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import QuartzCore

class CircleMask {
    
    //
    // Function to create a RW logo shape layer
    //
    class func circleMaskLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.geometryFlipped = true
        
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: CGFloat(5), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        //create a shape layer
        layer.path = circlePath.CGPath
        layer.bounds = CGPathGetBoundingBox(layer.path)
        
        return layer
    }
    
}