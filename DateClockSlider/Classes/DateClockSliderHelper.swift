//
//  DateClockSliderHelper.swift
//  DateClockSlider
//
//  Created by 岩佐晃也 on 2018/10/20.
//

import UIKit

internal struct Interval {
    var min: CGFloat = 0.0
    var max: CGFloat = 0.0
    var rounds: Int
    
    init(min: CGFloat, max: CGFloat, rounds: Int = 1) {
        assert(min <= max && rounds > 0, NSLocalizedString("Illegal interval", comment: ""))
        
        self.min = min
        self.max = max
        self.rounds = rounds
    }
}

internal struct Circle {
    var origin = CGPoint.zero
    var radius: CGFloat = 0
    
    init(origin: CGPoint, radius: CGFloat) {
        assert(radius >= 0, NSLocalizedString("Illegal radius value", comment: ""))
        
        self.origin = origin
        self.radius = radius
    }
}

internal struct Arc {
    
    var circle = Circle(origin: CGPoint.zero, radius: 0)
    var startAngle: CGFloat = 0.0
    var endAngle: CGFloat = 0.0
    
    init(circle: Circle, startAngle: CGFloat, endAngle: CGFloat) {
        
        self.circle = circle
        self.startAngle = startAngle
        self.endAngle = endAngle
    }
}

// MARK: - Internal Extensions
internal extension CGVector {
    
    /**
     Calculate the vector between two points
     
     - parameter source:      the source point
     - parameter end:       the destination point
     
     - returns: returns the vector between source and the end point
     */
    init(sourcePoint source: CGPoint, endPoint end: CGPoint) {
        let dx = end.x - source.x
        let dy = end.y - source.y
        self.init(dx: dx, dy: dy)
    }
    
    func dotProduct(_ v: CGVector) -> CGFloat {
        let dotProduct = (dx * v.dx) + (dy * v.dy)
        return dotProduct
    }
    
    func determinant(_ v: CGVector) -> CGFloat {
        let determinant = (v.dx * dy) - (dx * v.dy)
        return determinant
    }
    
    static func dotProductAndDeterminant(fromSourcePoint source: CGPoint, firstPoint first: CGPoint, secondPoint second: CGPoint) -> (dotProduct: Float, determinant: Float) {
        let u = CGVector(sourcePoint: source, endPoint: first)
        let v = CGVector(sourcePoint: source, endPoint: second)
        
        let dotProduct = u.dotProduct(v)
        let determinant = u.determinant(v)
        return (Float(dotProduct), Float(determinant))
    }
}


internal class DateClockSliderHelper {
    
    static let circleMinValue: CGFloat = 0
    static let circleMaxValue: CGFloat = CGFloat(2 * Double.pi)
    static let circleInitialAngle: CGFloat = -CGFloat(Double.pi / 2)
    
    internal static func scaleToAngle(value aValue: CGFloat, inInterval oldInterval: Interval) -> CGFloat {
        let angleInterval = Interval(min: circleMinValue , max: circleMaxValue)
        
        let angle = scaleValue(aValue, fromInterval: oldInterval, toInterval: angleInterval)
        return angle
    }
    
    internal static func scaleValue(_ value: CGFloat, fromInterval source: Interval, toInterval destination: Interval) -> CGFloat {
        let sourceRange = (source.max - source.min) / CGFloat(source.rounds)
        let destinationRange = (destination.max - destination.min) / CGFloat(destination.rounds)
        let scaledValue = source.min + (value - source.min).truncatingRemainder(dividingBy: sourceRange)
        let newValue = (((scaledValue - source.min) * destinationRange) / sourceRange) + destination.min
        
        return newValue
    }
    
    internal static func endPoint(fromCircle circle: Circle, angle: CGFloat) -> CGPoint {
        /*
         to get coordinate from angle of circle
         https://www.mathsisfun.com/polar-cartesian-coordinates.html
         */
        
        let x = circle.radius * cos(angle) + circle.origin.x // cos(α) = x / radius
        let y = circle.radius * sin(angle) + circle.origin.y // sin(α) = y / radius
        let point = CGPoint(x: x, y: y)
        
        return point
    }
    
    internal static func delta(in interval: Interval, for angle: CGFloat, oldValue: CGFloat) -> CGFloat {
        let angleIntreval = Interval(min: circleMinValue , max: circleMaxValue)
        
        let oldAngle = scaleToAngle(value: oldValue, inInterval: interval)
        let deltaAngle = self.angle(from: oldAngle, to: angle)
        
        return scaleValue(deltaAngle, fromInterval: angleIntreval, toInterval: interval)
    }
    
    internal static func angle(betweenFirstPoint firstPoint: CGPoint, secondPoint: CGPoint, inCircleWithCenter center: CGPoint) -> CGFloat {
        /*
         we get the angle by using two vectors
         http://www.vitutor.com/geometry/vec/angle_vectors.html
         https://www.mathsisfun.com/geometry/unit-circle.html
         https://en.wikipedia.org/wiki/Dot_product
         https://en.wikipedia.org/wiki/Determinant
         */
        
        let uv = CGVector.dotProductAndDeterminant(fromSourcePoint: center, firstPoint: firstPoint, secondPoint: secondPoint)
        let angle = atan2(uv.determinant, uv.dotProduct)
        
        // change the angle interval
        let newAngle = (angle < 0) ? -angle : Float(Double.pi * 2) - angle
        
        return CGFloat(newAngle)
    }
    
    private static  func angle(from alpha: CGFloat, to beta: CGFloat) -> CGFloat {
        let halfValue = circleMaxValue/2
        // Rotate right
        let offset = alpha >= halfValue ? circleMaxValue - alpha : -alpha
        let offsetBeta = beta + offset
        
        if offsetBeta > halfValue {
            return offsetBeta - circleMaxValue
        }
        else {
            return offsetBeta
        }
    }
    
}
