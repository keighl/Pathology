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
    case invalid = ""
    case moveToPoint = "move"
    case addLineToPoint = "line"
    case addQuadCurveToPoint = "quad"
    case addCurveToPoint = "curve"
    case closeSubpath = "close"
}

public struct Element {
    var type: ElementType = .invalid
    var points: [CGPoint] = []
    
    public var dictionary: [String: Any] {
        return [
            "type": type.rawValue as Any,
            "pts": points.map {point in
                return [point.x, point.y]
            }
        ]
    }
    
    public func toJSON(options: JSONSerialization.WritingOptions) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: options)
        return data
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
        if let type = dictionary["type"] as? String {
            if let ptype = ElementType(rawValue: type) {
                self.type = ptype
            }
        }
        if let points = dictionary["pts"] as? [[CGFloat]] {
            self.points = points.map({pt in
                return CGPoint(x: pt[0], y: pt[1])
            })
        }
    }
}
