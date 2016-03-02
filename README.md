# Pathology

[![Build Status](https://travis-ci.org/keighl/Pathology.png?branch=master)](https://travis-ci.org/keighl/Pathology)
[![codecov.io](https://codecov.io/github/keighl/Pathology/coverage.svg?branch=master)](https://codecov.io/github/keighl/Pathology?branch=master)

Pathology is a library for encoding/decoding CGPath data.

### Extracting CGPath data

```swift
let bezierPath = UIBezierPath(
    roundedRect: CGRect(x: 50, y: 50, width: 200, height: 200),
    cornerRadius: 10)

let data = Pathology.extract(bezierPath.CGPath)
for el in data.elements {
    print("\(el.type)")
    print("\t\(el.points)")
}
```

Results

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
AddLineToPoint
  [(249.25088612153, 243.68506207169)]
AddCurveToPoint
  [(243.68506207169, 249.25088612153), (248.309404439556, 246.271761733743), (246.271761733743, 248.309404439556)]
AddCurveToPoint
  [(234.713350152704, 250.0), (241.31593055937, 250.0), (239.115070423815, 250.0)]
AddLineToPoint
  [(65.28665, 250.0)]
AddCurveToPoint
  [(56.6993457520553, 249.345041069756), (60.8849295761853, 250.0), (58.68406944063, 250.0)]
AddLineToPoint
  [(56.3149379283099, 249.25088612153)]
AddCurveToPoint
  [(50.7491138784702, 243.68506207169), (53.7282382662575, 248.309404439556), (51.6905955604437, 246.271761733743)]
AddCurveToPoint
  [(50.0, 234.713350152704), (50.0, 241.31593055937), (50.0, 239.115070423815)]
AddLineToPoint
  [(50.0, 65.28665)]
AddCurveToPoint
  [(50.654958930244, 56.6993457520553), (50.0, 60.8849295761853), (50.0, 58.68406944063)]
AddLineToPoint
  [(50.7491138784702, 56.3149379283099)]
AddCurveToPoint
  [(56.3149379283099, 50.7491138784702), (51.6905955604437, 53.7282382662575), (53.7282382662575, 51.6905955604437)]
AddCurveToPoint
  [(65.2866498472958, 50.0), (58.68406944063, 50.0), (60.8849295761853, 50.0)]
AddLineToPoint
  [(65.28665, 50.0)]
```

###
