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
    
    func testExtract() {
        let elements = Pathology.extract(testPath)
        XCTAssertEqual(elements.data[0].type, PathElementType.MoveToPoint)
        XCTAssertEqual(elements.data[0].points, [CGPointMake(0, 0)])
        XCTAssertEqual(elements.data[1].type, PathElementType.AddCurveToPoint)
        XCTAssertEqual(elements.data[1].points, [CGPointMake(75, 25), CGPointMake(50, 25), CGPointMake(70, 10)])
        XCTAssertEqual(elements.data[2].type, PathElementType.AddLineToPoint)
        XCTAssertEqual(elements.data[2].points, [CGPointMake(50, 50)])
        XCTAssertEqual(elements.data[3].type, PathElementType.AddQuadCurveToPoint)
        XCTAssertEqual(elements.data[3].points, [CGPointMake(74, 75), CGPointMake(75, 150)])
        XCTAssertEqual(elements.data[4].type, PathElementType.AddLineToPoint)
        XCTAssertEqual(elements.data[4].points, [CGPointMake(0, 0)])
        XCTAssertEqual(elements.data[5].type, PathElementType.CloseSubpath)
        XCTAssertEqual(elements.data[5].points, [])
    }
    
    func testElementsRaw() {
        let elements = PathElements(data: [PathElementData(type: PathElementType.AddLineToPoint, points: [CGPointMake(100, 100)])])
        let result = elements.raw()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0]["type"] as? String, PathElementType.AddLineToPoint.rawValue)
        XCTAssertEqual((result[0]["points"] as? [[CGFloat]])!, [[100, 100]])
    }
    
    func testElementDataRaw() {
        let data = PathElementData(type: PathElementType.AddLineToPoint, points: [CGPointMake(100, 100)])
        let result = data.raw()
        XCTAssertEqual(result["type"] as? String, PathElementType.AddLineToPoint.rawValue)
        XCTAssertEqual((result["points"] as? [[CGFloat]])!, [[100, 100]])
    }
    
    func testElementParse() {
        let data = testPathJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        do {
            if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]] {
                let elements = Pathology.parseRawPathData(jsonArray)
                
                XCTAssertEqual(elements.data[0].type, PathElementType.MoveToPoint)
                XCTAssertEqual(elements.data[0].points, [CGPointMake(0, 0)])
                XCTAssertEqual(elements.data[1].type, PathElementType.AddCurveToPoint)
                XCTAssertEqual(elements.data[1].points, [CGPointMake(75, 25), CGPointMake(50, 25), CGPointMake(70, 10)])
                XCTAssertEqual(elements.data[2].type, PathElementType.AddLineToPoint)
                XCTAssertEqual(elements.data[2].points, [CGPointMake(50, 50)])
                XCTAssertEqual(elements.data[3].type, PathElementType.AddQuadCurveToPoint)
                XCTAssertEqual(elements.data[3].points, [CGPointMake(74, 75), CGPointMake(75, 150)])
                XCTAssertEqual(elements.data[4].type, PathElementType.AddLineToPoint)
                XCTAssertEqual(elements.data[4].points, [CGPointMake(0, 0)])
                XCTAssertEqual(elements.data[5].type, PathElementType.CloseSubpath)
                XCTAssertEqual(elements.data[5].points, [])
                XCTAssertEqual(elements.data[6].type, PathElementType.Invalid)
                XCTAssertEqual(elements.data[6].points, [])
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testBuildPath() {
        let elements = Pathology.extract(testPath)
        let builtPath = elements.buildPath()
        XCTAssert(CGPathEqualToPath(testPath, builtPath), "Build path doesn't match")
    }
    
    func testJSONEndToEnd() {
        let elements = Pathology.extract(testPath)
        do {
            let marshaledData = try NSJSONSerialization.dataWithJSONObject(elements.raw(), options: NSJSONWritingOptions.PrettyPrinted)
            print(NSString(data: marshaledData, encoding: NSUTF8StringEncoding))
            let unmarshaledData = try NSJSONSerialization.JSONObjectWithData(marshaledData, options: [])
            if let ud = unmarshaledData as? [[String: AnyObject]] {
                let parsedElements = Pathology.parseRawPathData(ud)
                XCTAssert(CGPathEqualToPath(testPath, parsedElements.buildPath()), "Build path doesn't match")
            } else {
                XCTFail("Couldn't parse unmarshaled JSON")
            }
            
        } catch {
            XCTFail("\(error)")
        }
    
    }
    
}
