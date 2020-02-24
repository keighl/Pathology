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
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: 50, y: 25), control1: CGPoint(x: 70, y: 10), control2: CGPoint(x: 75, y: 25))
        path.addLine(to: CGPoint(x: 50, y: 50))
        path.addQuadCurve(to: CGPoint(x: 75, y: 150), control: CGPoint(x: 74, y: 75))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        
        return path
    }()
    
    let testPathJSON = "{\"elements\": [{\"points\":[[0,0]],\"type\":\"move\"},{\"points\":[[50,25],[70,10],[75,25]],\"type\":\"curve\"},{\"points\":[[50,50]],\"type\":\"line\"},{\"points\":[[75,150],[74,75]],\"type\":\"quad\"},{\"points\":[[0,0]],\"type\":\"line\"},{\"points\":[],\"type\":\"close\"},{\"points\":[],\"type\":\"invalid\"}]}"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_Extract() {
        let pathData = Pathology.extract(path: testPath)
        XCTAssertEqual(pathData.elements[0].type, ElementType.moveToPoint)
        XCTAssertEqual(pathData.elements[0].points, [CGPoint(x: 0, y: 0)])
        XCTAssertEqual(pathData.elements[1].type, ElementType.addCurveToPoint)
        XCTAssertEqual(pathData.elements[1].points, [CGPoint(x: 50, y: 25), CGPoint(x: 70, y: 10), CGPoint(x: 75, y: 25)])
        XCTAssertEqual(pathData.elements[2].type, ElementType.addLineToPoint)
        XCTAssertEqual(pathData.elements[2].points, [CGPoint(x: 50, y: 50)])
        XCTAssertEqual(pathData.elements[3].type, ElementType.addQuadCurveToPoint)
        XCTAssertEqual(pathData.elements[3].points, [CGPoint(x: 75, y: 150), CGPoint(x: 74, y: 75)])
        XCTAssertEqual(pathData.elements[4].type, ElementType.addLineToPoint)
        XCTAssertEqual(pathData.elements[4].points, [CGPoint(x: 0, y: 0)])
        XCTAssertEqual(pathData.elements[5].type, ElementType.closeSubpath)
        XCTAssertEqual(pathData.elements[5].points, [])
    }
    
    ////////
    
    func test_Path_ToArray() {
        let pathData = Path(elements: [Element(type: .addLineToPoint, points: [CGPoint(x: 100, y: 100)])])
        let result = pathData.array
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0]["type"] as? String, ElementType.addLineToPoint.rawValue)
        XCTAssertEqual((result[0]["points"] as? [[CGFloat]])!, [[100, 100]])
    }
    
    func test_Path_ToJSON() {
        let pathData = Path(
            elements: [
                Element(type: .addLineToPoint, points: [CGPoint(x: 100, y: 100)])
            ]
        )
        
        do {
            let result = try pathData.toJSON()
            let resultString = String(data: result, encoding: .utf8)
            let expected = "{\"elements\":[{\"type\":\"line\",\"points\":[[100,100]]}]}"
            XCTAssertEqual(resultString, expected)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_Path_FromJSON() {
        let json = testPathJSON.data(using: .utf8, allowLossyConversion: false) ?? Data()
        
        do {
            let pathData = try Path.fromJSON(json)
            
            XCTAssertEqual(pathData.elements[0].type, ElementType.moveToPoint)
            XCTAssertEqual(pathData.elements[0].points, [CGPoint(x: 0, y: 0)])
            XCTAssertEqual(pathData.elements[1].type, ElementType.addCurveToPoint)
            XCTAssertEqual(pathData.elements[1].points, [CGPoint(x: 50, y: 25), CGPoint(x: 70, y: 10), CGPoint(x: 75, y: 25)])
            XCTAssertEqual(pathData.elements[2].type, ElementType.addLineToPoint)
            XCTAssertEqual(pathData.elements[2].points, [CGPoint(x: 50, y: 50)])
            XCTAssertEqual(pathData.elements[3].type, ElementType.addQuadCurveToPoint)
            XCTAssertEqual(pathData.elements[3].points, [CGPoint(x: 75, y: 150), CGPoint(x: 74, y: 75)])
            XCTAssertEqual(pathData.elements[4].type, ElementType.addLineToPoint)
            XCTAssertEqual(pathData.elements[4].points, [CGPoint(x: 0, y: 0)])
            XCTAssertEqual(pathData.elements[5].type, ElementType.closeSubpath)
            XCTAssertEqual(pathData.elements[5].points, [])
            XCTAssertEqual(pathData.elements[6].type, ElementType.invalid)
            XCTAssertEqual(pathData.elements[6].points, [])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_Path_FromJSON_Fail() {
        let json = "CHEESE".data(using: .utf8, allowLossyConversion: false) ?? Data()
        
        if let _ = try? Path.fromJSON(json) {
            XCTFail("Shoulda failed!")
        }
    }
    
    func test_Path_FromData() {
        let data = testPathJSON.data(using: .utf8, allowLossyConversion: false)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: AnyObject]] {
                let pathData = Path(data: jsonArray)
                
                XCTAssertEqual(pathData.elements[0].type, ElementType.moveToPoint)
                XCTAssertEqual(pathData.elements[0].points, [CGPoint(x: 0, y: 0)])
                XCTAssertEqual(pathData.elements[1].type, ElementType.addCurveToPoint)
                XCTAssertEqual(pathData.elements[1].points, [CGPoint(x: 50, y: 25), CGPoint(x: 70, y: 10), CGPoint(x: 75, y: 25)])
                XCTAssertEqual(pathData.elements[2].type, ElementType.addLineToPoint)
                XCTAssertEqual(pathData.elements[2].points, [CGPoint(x: 50, y: 50)])
                XCTAssertEqual(pathData.elements[3].type, ElementType.addQuadCurveToPoint)
                XCTAssertEqual(pathData.elements[3].points, [CGPoint(x: 75, y: 150), CGPoint(x: 74, y: 75)])
                XCTAssertEqual(pathData.elements[4].type, ElementType.addLineToPoint)
                XCTAssertEqual(pathData.elements[4].points, [CGPoint(x: 0, y: 0)])
                XCTAssertEqual(pathData.elements[5].type, ElementType.closeSubpath)
                XCTAssertEqual(pathData.elements[5].points, [])
                XCTAssertEqual(pathData.elements[6].type, ElementType.invalid)
                XCTAssertEqual(pathData.elements[6].points, [])
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_Path_CGPath() {
        let pathData = Pathology.extract(path: testPath)
        let builtPath = pathData.cgPath
        XCTAssert(testPath == builtPath, "Build path doesn't match")
    }
    
    ////////
    
    func test_Element_ToDictionary() {
        let element = Element(type: ElementType.addLineToPoint, points: [CGPoint(x: 100, y: 100)])
        let result = element.dictionary
        XCTAssertEqual(result["type"] as? String, ElementType.addLineToPoint.rawValue)
        XCTAssertEqual((result["points"] as? [[CGFloat]])!, [[100, 100]])
    }
    
    func test_Element_ToJSON() {
        let element = Element(type: .addLineToPoint, points: [CGPoint(x: 100, y: 100)])
        
        do {
            let result = try element.toJSON()
            let resultString = String(data: result, encoding: .utf8)
            let expected = "{\"type\":\"line\",\"points\":[[100,100]]}"
            XCTAssertEqual(resultString, expected)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_thing() {
        
    }
}
