//
//  Element.swift
//  Pathology
//
//  Created by Kyle Truscott on 3/2/16.
//  Copyright © 2016 keighl. All rights reserved.
//

import Foundation
import QuartzCore

public enum ElementType : String, Codable {
    case invalid
    case moveToPoint = "move"
    case addLineToPoint = "line"
    case addQuadCurveToPoint = "quad"
    case addCurveToPoint = "curve"
    case closeSubpath = "close"
}

public struct Element: Codable {
    var type: ElementType = .invalid
    var points: [CGPoint] = []
    
    public var dictionary: [String: Any] {
        return [
            "type": type.rawValue as Any,
            "points": points.map { [$0.x, $0.y] }
        ]
    }
    
    public var endPoint: CGPoint {
        if points.count >= 1 {
            return points[0]
        }
        
        return .zero
    }
    
    public var ctrlPoint1: CGPoint {
        if points.count >= 2 {
            return points[1]
        }
        
        return .zero
    }
    
    public var ctrlPoint2: CGPoint {
        if points.count >= 3 {
            return points[2]
        }
        
        return .zero
    }
}

extension Element {
    public init(dictionary: [String: AnyObject]) {
        if let type = dictionary["type"] as? String,
            let ptype = ElementType(rawValue: type) {
                self.type = ptype
        }
        
        if let points = dictionary["points"] as? [[CGFloat]] {
            self.points = points.map { CGPoint(x: $0[0], y: $0[1]) }
        }
    }
}
