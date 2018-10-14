//
//  Path.swift
//  Pathology
//
//  Created by Kyle Truscott on 3/2/16.
//  Copyright © 2016 keighl. All rights reserved.
//

import Foundation
import QuartzCore

public struct Path {
    var elements: [Element] = []
    
    public var array: [[String: Any]] {
        return elements.map { (el) in
            return el.dictionary
        }
    }
    
    public var json: Data? {
        return try? json(options: .init(rawValue: 0))
    }
    
    public func json(options: JSONSerialization.WritingOptions) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: array, options: options)
        return data
    }
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        for el in elements {
            switch el.type {
            case .moveToPoint:
                path.move(to: CGPoint(x: el.endPoint.x, y: el.endPoint.y))
            case .addLineToPoint:
                path.addLine(to: CGPoint(x: el.endPoint.x, y: el.endPoint.y))
                break
            case .addQuadCurveToPoint:
                path.addQuadCurve(to:      CGPoint(x: el.ctrlPoint1.x, y: el.ctrlPoint1.y),
                                  control: CGPoint(x: el.endPoint.x,   y: el.endPoint.y  ))
                break
            case .addCurveToPoint:
                path.addCurve(to:       CGPoint(x: el.ctrlPoint1.x, y: el.ctrlPoint1.y),
                              control1: CGPoint(x: el.ctrlPoint2.x, y: el.ctrlPoint2.y),
                              control2: CGPoint(x: el.endPoint.x,   y: el.endPoint.y  ))
                break
            case .closeSubpath:
                path.closeSubpath()
                break
            case .invalid:
                break
            }
        }
        return path
    }
}


extension Path {
    public init?(json: Data) {
        do {
            let obj = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions(rawValue: 0))
            if let arr = obj as? [[String: AnyObject]] {
                self.elements = arr.map { el in
                    return Element(dictionary: el)
                }
            }
        } catch {
            return nil
        }
    }
    
    public init(data: [[String: AnyObject]]) {
        self.elements = data.map { el in
            return Element(dictionary: el)
        }
    }
}
