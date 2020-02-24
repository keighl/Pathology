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
        return elements.map { $0.dictionary }
    }
    
    public var json: Data? {
        try? json(options: .init(rawValue: 0))
    }
    
    public func json(options: JSONSerialization.WritingOptions = []) throws -> Data {
        try JSONSerialization.data(withJSONObject: array, options: options)
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
