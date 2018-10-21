//
//  DateClockSlider+Draw.swift
//  DateClockSlider
//
//  Created by 岩佐晃也 on 2018/10/20.
//

import UIKit

extension DateClockSlider {
    
    internal static func drawDisk(withArc arc: Arc, path: UIBezierPath) {
        let circle = arc.circle
        let origin = circle.origin
        
        path.lineWidth = 0
        path.addArc(withCenter: origin, radius: circle.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, clockwise: false)
        path.move(to: origin)
        path.fill()
        path.close()
    }
    
    internal static func drawArc(withArc arc: Arc, lineWidth: CGFloat = 2, mode: CGPathDrawingMode = .fillStroke, path: UIBezierPath) {
        let circle = arc.circle
        let origin = circle.origin
        
        path.lineWidth = lineWidth
        path.addArc(withCenter: origin, radius: circle.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, clockwise: false)
        path.move(to: origin)
        path.stroke()
        path.close()
    }
    
    internal func drawBackground() {
        let path = UIBezierPath()
        UIColor.white.setFill()
        UIColor.white.setStroke()
        
        path.lineWidth = 1
        path.move(to: bounds.origin)
        path.addLine(to: bounds.origin)
        path.addLine(to: CGPoint(x: bounds.maxX, y: 0))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: 0, y: bounds.maxY))
        path.move(to: CGPoint(x: bounds.midX, y: bounds.midY))
        path.fill()
        path.close()
    }
    
    internal func drawDateClockSlider() {
        let path = UIBezierPath()
        UIColor.blue.setStroke()
        
        let circle = Circle(origin: CGPoint(x: bounds.midX, y: bounds.midY), radius: 10)
        let sliderArc = Arc(circle: circle, startAngle: 0, endAngle: CGFloat(Double.pi * 2))
        DateClockSlider.drawArc(withArc: sliderArc, lineWidth: 10, path: path)
    }
    
    internal func drawFilledArc(fromAngle startAngle: CGFloat, toAngle endAngle: CGFloat) {
        UIColor.blue.setFill()
        UIColor.green.setStroke()
        
        let circle = Circle(origin: CGPoint(x: bounds.midX, y: bounds.midY), radius: self.radius)
        let arc = Arc(circle: circle, startAngle: startAngle, endAngle: endAngle)
        
        // fill Arc
        DateClockSlider.drawDisk(withArc: arc, path: UIBezierPath())
        // stroke Arc
        DateClockSlider.drawArc(withArc: arc, lineWidth: 4, path: UIBezierPath())
    }
    
}
