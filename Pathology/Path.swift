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
    
    func toArray() -> [[String: AnyObject]] {
        return elements.map({el in
            return el.toDictionary()
        })
    }
    
    public func toJSON(options: NSJSONWritingOptions) throws -> NSData {
        let data = try NSJSONSerialization.dataWithJSONObject(toArray(), options: options)
        return data
    }
    
    func CGPath() -> QuartzCore.CGPath {
        let path = CGPathCreateMutable()
        for el in elements {
            let endPoint = el.endPoint()
            let ctrl1 = el.ctrlPoint1()
            let ctrl2 = el.ctrlPoint2()
            
            switch el.type {
            case .MoveToPoint:
                CGPathMoveToPoint(path, nil, endPoint.x, endPoint.y)
            case .AddLineToPoint:
                CGPathAddLineToPoint(path, nil, endPoint.x, endPoint.y)
                break
            case .AddQuadCurveToPoint:
                CGPathAddQuadCurveToPoint(path, nil, ctrl1.x, ctrl1.y, endPoint.x, endPoint.y)
                break
            case .AddCurveToPoint:
                CGPathAddCurveToPoint(path, nil, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, endPoint.x, endPoint.y)
                break
            case .CloseSubpath:
                CGPathCloseSubpath(path)
                break
            case .Invalid:
                break
            }
        }
        return path
    }
}

extension Path {
    public init?(JSON: NSData) {
        do {
            let obj = try NSJSONSerialization.JSONObjectWithData(JSON, options: NSJSONReadingOptions(rawValue: 0))
            if let arr = obj as? [[String: AnyObject]] {
                self.elements = arr.map({ el in
                    return Element(dictionary: el)
                })
            }
        } catch {
            return nil
        }
    }
    
    public init(data: [[String: AnyObject]]) {
        self.elements = data.map({ el in
            return Element(dictionary: el)
        })
    }
}
