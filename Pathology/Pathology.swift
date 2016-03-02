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

public class Pathology {
    
    public class func extract(path: CGPath) -> Path {
        var pathData = Path(elements: [])
        pathApply(path) { element in
            switch (element.memory.type) {
            case CGPathElementType.MoveToPoint:
                pathData.elements.append(Element(type: .MoveToPoint, points: [
                    element.memory.points[0]
                ]))
            case .AddLineToPoint:
                pathData.elements.append(Element(type: .AddLineToPoint, points: [
                    element.memory.points[0],
                ]))
            case .AddQuadCurveToPoint:
                pathData.elements.append(Element(type: .AddQuadCurveToPoint, points: [
                    element.memory.points[1], // end pt
                    element.memory.points[0], // ctlpr pt
                ]))
            case .AddCurveToPoint:
                pathData.elements.append(Element(type: .AddCurveToPoint, points: [
                    element.memory.points[2], // end pt
                    element.memory.points[0], // ctlpr 1
                    element.memory.points[1], // ctlpr 2
                ]))
            case .CloseSubpath:
                pathData.elements.append(Element(type: .CloseSubpath, points: []))
            }
        }
        return pathData
    }
}




