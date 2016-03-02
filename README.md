# Pathology

[![Build Status](https://travis-ci.org/keighl/Pathology.png?branch=master)](https://travis-ci.org/keighl/Pathology)
[![codecov.io](https://codecov.io/github/keighl/Pathology/coverage.svg?branch=master)](https://codecov.io/github/keighl/Pathology?branch=master)

Pathology is a library for encoding/decoding CGPath data.

### Extracting CGPath data

```swift
let bezierPath = UIBezierPath(
    roundedRect: CGRect(x: 50, y: 50, width: 200, height: 200),
    cornerRadius: 10)

let pathData = Pathology.extract(bezierPath.CGPath)
for el in pathData.elements {
    print("\(el.type)")
    print("\t\(el.points)")
}
```

Result &darr;

```
MoveToPoint
  [(65.28665, 50.0)]
AddLineToPoint
  [(234.71335, 50.0)]
AddCurveToPoint
  [(243.300654247945, 50.654958930244), (239.115070423815, 50.0), (241.31593055937, 50.0)]
AddLineToPoint
  [(243.68506207169, 50.7491138784702)]
AddCurveToPoint
  [(249.25088612153, 56.3149379283099), (246.271761733743, 51.6905955604437), (248.309404439556, 53.7282382662575)]
AddCurveToPoint
  [(250.0, 65.2866498472958), (250.0, 58.68406944063), (250.0, 60.8849295761853)]
AddLineToPoint
  [(250.0, 234.71335)]
AddCurveToPoint
  [(249.345041069756, 243.300654247945), (250.0, 239.115070423815), (250.0, 241.31593055937)]

etc...
```

### Encode JSON

```swift
let bezierPath = UIBezierPath(rect: CGRect(x: 50, y: 50, width: 200, height: 200))
let pathData = Pathology.extract(bezierPath.CGPath)

do {
  let json = try pathData.toJSON(NSJSONWritingOptions(rawValue: 0))
} catch {
  print("\(error)")
}

Result &darr;

```json
[{"points":[[50,50]],"type":"moveToPoint"},{"points":[[250,50]],"type":"addLineToPoint"},{"points":[[250,250]],"type":"addLineToPoint"},{"points":[[50,250]],"type":"addLineToPoint"},{"points":[],"type":"closeSubpath"}])
/Users/keighl/ios/Pathology/PathologyTests/PathologyTests.swift:80: error: -[PathologyTests_iOS.PathologyTests test_Path_ToJSON] : XCTAssertEqual failed: ("Optional([{"points":[[50,50]],"type":"moveToPoint"},{"points":[[250,50]],"type":"addLineToPoint"},{"points":[[250,250]],"type":"addLineToPoint"},{"points":[[50,250]],"type":"addLineToPoint"},{"points":[],"type":"closeSubpath"}]
```

### Decode JSON

Expects array payload like encoded result above &uarr;

```swift
if let pathData = Path(JSON: someJSONdata) {
  let bezierPath = UIBezierPath(CGPath: pathData.CGPath())
}

