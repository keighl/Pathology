//
//  Element.swift
//  Pathology
//
//  Created by Kyle Truscott on 3/2/16.
//  Copyright © 2016 keighl. All rights reserved.
//

import Foundation
import QuartzCore

public enum ElementType : String {
    case Invalid = ""
    case MoveToPoint = "move"
    case AddLineToPoint = "line"
    case AddQuadCurveToPoint = "quad"
    case AddCurveToPoint = "curve"
    case CloseSubpath = "close"
}

public struct Element {
    var type: ElementType = .Invalid
    var points: [CGPoint] = []
    
    public func toDictionary() -> [String: AnyObject] {
        return [
            "type": type.rawValue,
            "pts": points.map({point in
                return [point.x, point.y]
            })
        ]
    }
    
    public func toJSON(options: NSJSONWritingOptions) throws -> NSData {
        let data = try NSJSONSerialization.dataWithJSONObject(toDictionary(), options: options)
        return data
    }
    
    public func endPoint() -> CGPoint {
        if points.count >= 1 {
            return points[0]
        }
        return CGPointZero
    }
    
    public func ctrlPoint1() -> CGPoint {
        if points.count >= 2 {
            return points[1]
        }
        return CGPointZero
    }
    
    public func ctrlPoint2() -> CGPoint {
        if points.count >= 3 {
            return points[2]
        }
        return CGPointZero
    }
}


extension Element {
    public init(dictionary: [String: AnyObject]) {
        if let type = dictionary["type"] as? String {
            if let ptype = ElementType(rawValue: type) {
                self.type = ptype
            }
        }
        if let points = dictionary["pts"] as? [[CGFloat]] {
            self.points = points.map({pt in
                return CGPointMake(pt[0], pt[1])
            })
        }
    }
}
