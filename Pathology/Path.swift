//
//  Path.swift
//  Pathology
//
//  Created by Kyle Truscott on 3/2/16.
//  Copyright © 2016 keighl. All rights reserved.
//

import Foundation
import QuartzCore

public struct Path: Codable {
    var elements: [Element] = []
    
    public var array: [[String: Any]] {
        return elements.map { $0.dictionary }
    }
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        
        for element in elements {
            switch element.type {
            case .moveToPoint:
                path.move(to: element.endPoint)
            case .addLineToPoint:
                path.addLine(to: element.endPoint)
            case .addQuadCurveToPoint:
                path.addQuadCurve(
                    to: element.endPoint,
                    control: element.ctrlPoint1)
            case .addCurveToPoint:
                path.addCurve(
                    to: element.endPoint,
                    control1: element.ctrlPoint1,
                    control2: element.ctrlPoint2)
            case .closeSubpath:
                path.closeSubpath()
            case .invalid:
                break
            }
        }
        
        return path
    }
}


extension Path {    
    public init(data: [[String: AnyObject]]) {
        self.elements = data.map { Element(dictionary: $0) }
    }
}
