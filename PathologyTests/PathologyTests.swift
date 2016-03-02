//
//  PathologyTests.swift
//  PathologyTests
//
//  Created by Kyle Truscott on 3/1/16.
//  Copyright © 2016 keighl. All rights reserved.
//

import XCTest
@testable import Pathology

class PathologyTests: XCTestCase {
    
    let testPath: CGPath = {
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddCurveToPoint(path, nil, 50, 25, 70, 10, 75, 25)
        CGPathAddLineToPoint(path, nil, 50, 50)
        CGPathAddQuadCurveToPoint(path, nil, 75, 150, 74, 75)
        CGPathAddLineToPoint(path, nil, 0, 0)
        CGPathCloseSubpath(path)
        return path
    }()
    
    let testPathJSON = "[{\"points\":[[0,0]],\"type\":\"moveToPoint\"},{\"points\":[[75,25],[50,25],[70,10]],\"type\":\"addCurveToPoint\"},{\"points\":[[50,50]],\"type\":\"addLineToPoint\"},{\"points\":[[74,75],[75,150]],\"type\":\"addQuadCurveToPoint\"},{\"points\":[[0,0]],\"type\":\"addLineToPoint\"},{\"points\":[],\"type\":\"closeSubpath\"},{\"points\":[],\"type\":\"INVALID\"}]"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_Extract() {
        let pathData = Pathology.extract(testPath)
        XCTAssertEqual(pathData.elements[0].type, PTHElementType.MoveToPoint)
        XCTAssertEqual(pathData.elements[0].points, [CGPointMake(0, 0)])
        XCTAssertEqual(pathData.elements[1].type, PTHElementType.AddCurveToPoint)
        XCTAssertEqual(pathData.elements[1].points, [CGPointMake(75, 25), CGPointMake(50, 25), CGPointMake(70, 10)])
        XCTAssertEqual(pathData.elements[2].type, PTHElementType.AddLineToPoint)
        XCTAssertEqual(pathData.elements[2].points, [CGPointMake(50, 50)])
        XCTAssertEqual(pathData.elements[3].type, PTHElementType.AddQuadCurveToPoint)
        XCTAssertEqual(pathData.elements[3].points, [CGPointMake(74, 75), CGPointMake(75, 150)])
        XCTAssertEqual(pathData.elements[4].type, PTHElementType.AddLineToPoint)
        XCTAssertEqual(pathData.elements[4].points, [CGPointMake(0, 0)])
        XCTAssertEqual(pathData.elements[5].type, PTHElementType.CloseSubpath)
        XCTAssertEqual(pathData.elements[5].points, [])
    }
    
    func test_Path_ToArray() {
        let pathData = PTHPath(elements: [PTHElement(type: PTHElementType.AddLineToPoint, points: [CGPointMake(100, 100)])])
        let result = pathData.toArray()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0]["type"] as? String, PTHElementType.AddLineToPoint.rawValue)
        XCTAssertEqual((result[0]["points"] as? [[CGFloat]])!, [[100, 100]])
    }
    
    func test_Element_ToDictionary() {
        let elementData = PTHElement(type: PTHElementType.AddLineToPoint, points: [CGPointMake(100, 100)])
        let result = elementData.toDictionary()
        XCTAssertEqual(result["type"] as? String, PTHElementType.AddLineToPoint.rawValue)
        XCTAssertEqual((result["points"] as? [[CGFloat]])!, [[100, 100]])
    }
    
    func test_Path_FromData() {
        let data = testPathJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        do {
            if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]] {
                let pathData = PTHPath(data: jsonArray)
                
                XCTAssertEqual(pathData.elements[0].type, PTHElementType.MoveToPoint)
                XCTAssertEqual(pathData.elements[0].points, [CGPointMake(0, 0)])
                XCTAssertEqual(pathData.elements[1].type, PTHElementType.AddCurveToPoint)
                XCTAssertEqual(pathData.elements[1].points, [CGPointMake(75, 25), CGPointMake(50, 25), CGPointMake(70, 10)])
                XCTAssertEqual(pathData.elements[2].type, PTHElementType.AddLineToPoint)
                XCTAssertEqual(pathData.elements[2].points, [CGPointMake(50, 50)])
                XCTAssertEqual(pathData.elements[3].type, PTHElementType.AddQuadCurveToPoint)
                XCTAssertEqual(pathData.elements[3].points, [CGPointMake(74, 75), CGPointMake(75, 150)])
                XCTAssertEqual(pathData.elements[4].type, PTHElementType.AddLineToPoint)
                XCTAssertEqual(pathData.elements[4].points, [CGPointMake(0, 0)])
                XCTAssertEqual(pathData.elements[5].type, PTHElementType.CloseSubpath)
                XCTAssertEqual(pathData.elements[5].points, [])
                XCTAssertEqual(pathData.elements[6].type, PTHElementType.Invalid)
                XCTAssertEqual(pathData.elements[6].points, [])
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_Path_CGPath() {
        let pathData = Pathology.extract(testPath)
        let builtPath = pathData.CGPath()
        XCTAssert(CGPathEqualToPath(testPath, builtPath), "Build path doesn't match")
    }
    
    func test_JSON_EndToEnd() {
        let pathData = Pathology.extract(testPath)
        do {
            let marshaledData = try NSJSONSerialization.dataWithJSONObject(pathData.toArray(), options: NSJSONWritingOptions.PrettyPrinted)
            let unmarshaledData = try NSJSONSerialization.JSONObjectWithData(marshaledData, options: [])
            if let ud = unmarshaledData as? [[String: AnyObject]] {
                let parsedElements = Pathology.parseRawPathData(ud)
                XCTAssert(CGPathEqualToPath(testPath, parsedElements.CGPath()), "Build path doesn't match")
            } else {
                XCTFail("Couldn't parse unmarshaled JSON")
            }
            
        } catch {
            XCTFail("\(error)")
        }
    }
}
