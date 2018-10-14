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

private func apply(to path: CGPath, block: @escaping @convention(block) (UnsafePointer<CGPathElement>) -> Void) {
    let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
        let block = unsafeBitCast(info, to: PathApplier.self)
        block(element)
    }
    path.apply(info: unsafeBitCast(block, to: UnsafeMutableRawPointer.self), function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
}

public func extract(path: CGPath) -> Path {
    var pathData = Path(elements: [])
    apply(to: path) { (element) in
        switch (element.pointee.type) {
        case CGPathElementType.moveToPoint:
            pathData.elements.append(Element(type: .moveToPoint, points: [
                element.pointee.points[0]
            ]))
        case .addLineToPoint:
            pathData.elements.append(Element(type: .addLineToPoint, points: [
                element.pointee.points[0],
            ]))
        case .addQuadCurveToPoint:
            pathData.elements.append(Element(type: .addQuadCurveToPoint, points: [
                element.pointee.points[1], // end pt
                element.pointee.points[0], // ctlpr pt
            ]))
        case .addCurveToPoint:
            pathData.elements.append(Element(type: .addCurveToPoint, points: [
                element.pointee.points[2], // end pt
                element.pointee.points[0], // ctlpr 1
                element.pointee.points[1], // ctlpr 2
            ]))
        case .closeSubpath:
            pathData.elements.append(Element(type: .closeSubpath, points: []))
        }
    }
    return pathData
}
