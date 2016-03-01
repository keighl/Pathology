//
//  Pathology.swift
//  Pathology
//
//  Created by Kyle Truscott on 3/1/16.
//  Copyright © 2016 keighl. All rights reserved.
//

import Foundation
import QuartzCore

typealias PathApplier = @convention(block) (UnsafePointer<CGPathElement>) -> Void

func pathApply(path: CGPath!, block: PathApplier) {
    let callback: @convention(c) (UnsafeMutablePointer<Void>, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
        let block = unsafeBitCast(info, PathApplier.self)
        block(element)
    }
    
    CGPathApply(path, unsafeBitCast(block, UnsafeMutablePointer<Void>.self), unsafeBitCast(callback, CGPathApplierFunction.self))
}

public enum PathologyError: ErrorType {
    case InvalidPathElementJSONData
    case InvalidPathElement
}

public enum PathElementType : String {
    case Invalid = ""
    case MoveToPoint = "moveToPoint"
    case AddLineToPoint = "addLineToPoint"
    case AddQuadCurveToPoint = "addQuadCurveToPoint"
    case AddCurveToPoint = "addCurveToPoint"
    case CloseSubpath = "closeSubpath"
}

public struct PathElements {
    var data: [PathElementData] = []
    
    func raw() -> [[String: AnyObject]] {
        return data.map({el in
            return el.raw()
        })
    }
    
    func buildPath() -> CGPath {
        let path = CGPathCreateMutable()
        for el in data {
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

public struct PathElementData {
    var type: PathElementType = .Invalid
    var points: [CGPoint] = []
    
    public func raw() -> [String: AnyObject] {
        return [
            "type": type.rawValue,
            "points": points.map({point in
                return [point.x, point.y]
            })
        ]
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

extension PathElementData {
    public init(rawDictionary: [String: AnyObject]) {
        if let type = rawDictionary["type"] as? String {
            if let ptype = PathElementType(rawValue: type) {
                self.type = ptype
            }
        }
        if let points = rawDictionary["points"] as? [[CGFloat]] {
            self.points = points.map({pt in
                return CGPointMake(pt[0], pt[1])
            })
        }
    }
}

public class Pathology {
    
    public class func extract(path: CGPath) -> PathElements {
        var elementsData = PathElements(data: [])
        pathApply(path) { element in
            switch (element.memory.type) {
            case CGPathElementType.MoveToPoint:
                elementsData.data.append(PathElementData(type: .MoveToPoint, points: [
                    element.memory.points[0]
                ]))
            case .AddLineToPoint:
                elementsData.data.append(PathElementData(type: .AddLineToPoint, points: [
                    element.memory.points[0],
                ]))
            case .AddQuadCurveToPoint:
                elementsData.data.append(PathElementData(type: .AddQuadCurveToPoint, points: [
                    element.memory.points[1], // end pt
                    element.memory.points[0], // ctlpr pt
                ]))
            case .AddCurveToPoint:
                elementsData.data.append(PathElementData(type: .AddCurveToPoint, points: [
                    element.memory.points[2], // end pt
                    element.memory.points[0], // ctlpr 1
                    element.memory.points[1], // ctlpr 2
                ]))
            case .CloseSubpath:
                elementsData.data.append(PathElementData(type: .CloseSubpath, points: []))
            }
        }
        return elementsData
    }
    
    public class func parseRawPathData(data: [[String: AnyObject]]) -> PathElements {
        return PathElements(data: data.map({ el in
            return PathElementData(rawDictionary: el)
        }))
    }
}




