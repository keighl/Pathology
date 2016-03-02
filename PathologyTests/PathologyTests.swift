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
    
    let testPathJSON = "[{\"pts\":[[0,0]],\"type\":\"move\"},{\"pts\":[[75,25],[50,25],[70,10]],\"type\":\"curve\"},{\"pts\":[[50,50]],\"type\":\"line\"},{\"pts\":[[74,75],[75,150]],\"type\":\"quad\"},{\"pts\":[[0,0]],\"type\":\"line\"},{\"pts\":[],\"type\":\"close\"},{\"pts\":[],\"type\":\"invalid\"}]"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_Extract() {
        let pathData = Pathology.extract(testPath)
        XCTAssertEqual(pathData.elements[0].type, ElementType.MoveToPoint)
        XCTAssertEqual(pathData.elements[0].points, [CGPointMake(0, 0)])
        XCTAssertEqual(pathData.elements[1].type, ElementType.AddCurveToPoint)
        XCTAssertEqual(pathData.elements[1].points, [CGPointMake(75, 25), CGPointMake(50, 25), CGPointMake(70, 10)])
        XCTAssertEqual(pathData.elements[2].type, ElementType.AddLineToPoint)
        XCTAssertEqual(pathData.elements[2].points, [CGPointMake(50, 50)])
        XCTAssertEqual(pathData.elements[3].type, ElementType.AddQuadCurveToPoint)
        XCTAssertEqual(pathData.elements[3].points, [CGPointMake(74, 75), CGPointMake(75, 150)])
        XCTAssertEqual(pathData.elements[4].type, ElementType.AddLineToPoint)
        XCTAssertEqual(pathData.elements[4].points, [CGPointMake(0, 0)])
        XCTAssertEqual(pathData.elements[5].type, ElementType.CloseSubpath)
        XCTAssertEqual(pathData.elements[5].points, [])
    }
    
    ////////
    
    func test_Path_ToArray() {
        let pathData = Path(elements: [Element(type: ElementType.AddLineToPoint, points: [CGPointMake(100, 100)])])
        let result = pathData.toArray()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0]["type"] as? String, ElementType.AddLineToPoint.rawValue)
        XCTAssertEqual((result[0]["pts"] as? [[CGFloat]])!, [[100, 100]])
    }
    
    func test_Path_ToJSON() {
        let pathData = Path(
            elements: [
                Element(type: ElementType.AddLineToPoint, points: [CGPointMake(100, 100)])
            ])
        do {
            let result = try pathData.toJSON(NSJSONWritingOptions(rawValue: 0))
            let resultString = NSString(data: result, encoding: NSUTF8StringEncoding)
            let expected = "[{\"pts\":[[100,100]],\"type\":\"line\"}]"
            XCTAssertEqual(resultString, expected)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_Path_FromJSON() {
        let JSON = testPathJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        if let pathData = Path(JSON: JSON) {
            XCTAssertEqual(pathData.elements[0].type, ElementType.MoveToPoint)
            XCTAssertEqual(pathData.elements[0].points, [CGPointMake(0, 0)])
            XCTAssertEqual(pathData.elements[1].type, ElementType.AddCurveToPoint)
            XCTAssertEqual(pathData.elements[1].points, [CGPointMake(75, 25), CGPointMake(50, 25), CGPointMake(70, 10)])
            XCTAssertEqual(pathData.elements[2].type, ElementType.AddLineToPoint)
            XCTAssertEqual(pathData.elements[2].points, [CGPointMake(50, 50)])
            XCTAssertEqual(pathData.elements[3].type, ElementType.AddQuadCurveToPoint)
            XCTAssertEqual(pathData.elements[3].points, [CGPointMake(74, 75), CGPointMake(75, 150)])
            XCTAssertEqual(pathData.elements[4].type, ElementType.AddLineToPoint)
            XCTAssertEqual(pathData.elements[4].points, [CGPointMake(0, 0)])
            XCTAssertEqual(pathData.elements[5].type, ElementType.CloseSubpath)
            XCTAssertEqual(pathData.elements[5].points, [])
            XCTAssertEqual(pathData.elements[6].type, ElementType.Invalid)
            XCTAssertEqual(pathData.elements[6].points, [])
        } else {
            XCTFail()
        }
    }
    
    func test_Path_FromJSON_Fail() {
        let JSON = "CHEESE".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        if let _ = Path(JSON: JSON) {
            XCTFail("Shoulda failed!")
        }
    }
    
    func test_Path_FromData() {
        let data = testPathJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        do {
            if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]] {
                let pathData = Path(data: jsonArray)
                
                XCTAssertEqual(pathData.elements[0].type, ElementType.MoveToPoint)
                XCTAssertEqual(pathData.elements[0].points, [CGPointMake(0, 0)])
                XCTAssertEqual(pathData.elements[1].type, ElementType.AddCurveToPoint)
                XCTAssertEqual(pathData.elements[1].points, [CGPointMake(75, 25), CGPointMake(50, 25), CGPointMake(70, 10)])
                XCTAssertEqual(pathData.elements[2].type, ElementType.AddLineToPoint)
                XCTAssertEqual(pathData.elements[2].points, [CGPointMake(50, 50)])
                XCTAssertEqual(pathData.elements[3].type, ElementType.AddQuadCurveToPoint)
                XCTAssertEqual(pathData.elements[3].points, [CGPointMake(74, 75), CGPointMake(75, 150)])
                XCTAssertEqual(pathData.elements[4].type, ElementType.AddLineToPoint)
                XCTAssertEqual(pathData.elements[4].points, [CGPointMake(0, 0)])
                XCTAssertEqual(pathData.elements[5].type, ElementType.CloseSubpath)
                XCTAssertEqual(pathData.elements[5].points, [])
                XCTAssertEqual(pathData.elements[6].type, ElementType.Invalid)
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
    
    ////////
    
    func test_Element_ToDictionary() {
        let elementData = Element(type: ElementType.AddLineToPoint, points: [CGPointMake(100, 100)])
        let result = elementData.toDictionary()
        XCTAssertEqual(result["type"] as? String, ElementType.AddLineToPoint.rawValue)
        XCTAssertEqual((result["pts"] as? [[CGFloat]])!, [[100, 100]])
    }
    
    func test_Element_ToJSON() {
        let elementData = Element(type: .AddLineToPoint, points: [CGPointMake(100, 100)])
        do {
            let result = try elementData.toJSON(NSJSONWritingOptions(rawValue: 0))
            let resultString = NSString(data: result, encoding: NSUTF8StringEncoding)
            let expected = "{\"pts\":[[100,100]],\"type\":\"line\"}"
            XCTAssertEqual(resultString, expected)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_thing() {
        
    }
}
