//
//  DateClockSlider.swift
//  DateClockSlider
//
//  Created by 岩佐晃也 on 2018/10/20.
//

import UIKit

open class DateClockSlider: UIControl {

    open var diskFillColor: UIColor = .clear
    open var diskColor: UIColor = .gray
    
    open var trackFillColor: UIColor = .clear
    open var trackColor: UIColor = .white
    
    open var lineWidth: CGFloat = 5.0
    open var backtrackLineWidth: CGFloat = 5.0
    
    open var trackShadowOffset: CGPoint = .zero
    open var trackShadowColor: UIColor = .gray
    
    open var thumbLineWidth: CGFloat = 4.0
    open var thumbRadius: CGFloat = 24.0
    
    open var endThumbTintColor: UIColor = .groupTableViewBackground
    open var endThumbStrokeHighlightedColor: UIColor = .blue
    open var endThumbStrokeColor: UIColor = .red
    open var endThumbImage: UIImage?
    
    open var numberOfDelimiters: CGFloat = 24.0 {
        didSet {
            assert(numberOfDelimiters > 0, "Number of delimiters has to be positive value!")
            setNeedsDisplay()
        }
    }
    
    open var numberOfRounds: Int = 1 {
        didSet {
            assert(numberOfRounds > 0, "Number of rounds has to be positive value!")
            setNeedsDisplay()
        }
    }
    
    open var minimumValue: CGFloat = 0.0 {
        didSet {
            if endPointValue < minimumValue {
                endPointValue = minimumValue
            }
        }
    }
    
    open var maximumValue: CGFloat = 1.0 {
        didSet {
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
        }
    }
    
    open var endPointValue: CGFloat = 0.0 {
        didSet {
            if oldValue == endPointValue {
                return
            }
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
            
            setNeedsDisplay()
        }
    }
    
    internal var radius: CGFloat {
        get {
            // the minimum between the height/2 and the width/2
            var radius =  min(bounds.midX, bounds.midY)
            // all elements should be inside the view rect, for that we should subtract the highest value between the radius of thumb and the line width
            radius -= max(lineWidth, (thumbRadius + thumbLineWidth))
            return radius
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public let endView = UIView()
    
    private let generator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        return generator
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup() {
        self.addSubview(self.endView)
        
        self.endView.isUserInteractionEnabled = false
        self.endView.backgroundColor = .purple
        self.endView.layer.cornerRadius = self.thumbRadius
        moveThumb(toAngle: endPointValue * CGFloat(Double.pi * 2) - CGFloat(Double.pi / 2))
    }
    
    override open func draw(_ rect: CGRect) {
        drawBackground()
        drawFilledArc(fromAngle: 0, toAngle: CGFloat(Double.pi * 2))
    }
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        sendActions(for: .editingDidBegin)
        let touchPosition = touch.location(in: self)
        let startPoint = CGPoint(x: bounds.midX, y: 0)
        let value = newValue(from: endPointValue, touch: touchPosition, start: startPoint)
        
        changeValue(value)
        
        return true
    }
    
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPosition = touch.location(in: self)
        let startPoint = CGPoint(x: bounds.midX, y: 0)
        let value = newValue(from: endPointValue, touch: touchPosition, start: startPoint)
        
        changeValue(value)
        sendActions(for: .valueChanged)
        
        return true
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        sendActions(for: .editingDidEnd)
    }
    
    public func getCurrentDateComponents() -> DateComponents {
        let jaLocale = Locale(identifier: "ja_JP")
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = jaLocale
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let dateComponents = DateComponents(calendar: calendar,
                                            hour: Int(endPointValue * 12),
                                            minute: Int(round((endPointValue * 12 - CGFloat(Int(endPointValue * 12))) * 2) * 30))
        
        return dateComponents
    }
    
    internal func newValue(from oldValue: CGFloat, touch touchPosition: CGPoint, start startPosition: CGPoint) -> CGFloat {
        let angle = DateClockSliderHelper.angle(betweenFirstPoint: startPosition, secondPoint: touchPosition, inCircleWithCenter: CGPoint(x: bounds.midX, y: bounds.midY))
        let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
        let deltaValue = DateClockSliderHelper.delta(in: interval, for: angle, oldValue: oldValue)
        
        var newValue = oldValue + deltaValue
        let range = maximumValue - minimumValue
        
        if newValue > maximumValue {
            newValue -= range
        }
        else if newValue < minimumValue {
            newValue += range
        }
        return newValue
    }
    
    internal func changeValue(_ value: CGFloat) {
        let roundedValue = round(value * numberOfDelimiters) / numberOfDelimiters
        let roundedEndPointValue = round(endPointValue * numberOfDelimiters) / numberOfDelimiters
        if roundedValue != roundedEndPointValue {
            generator.impactOccurred()
        }
        
        moveThumb(toAngle: value * CGFloat(Double.pi * 2) - CGFloat(Double.pi / 2))
        endPointValue = value
    }
    
    internal func moveThumb(toAngle angle: CGFloat) {
        let circle = Circle(origin: CGPoint(x: bounds.midX, y: bounds.midY), radius: self.radius)
        let endPoint = DateClockSliderHelper.endPoint(fromCircle: circle, angle: angle)
        
        self.endView.frame = CGRect(x: endPoint.x - self.thumbRadius, y: endPoint.y - self.thumbRadius, width: self.thumbRadius * 2, height: self.thumbRadius * 2)
    }
    
}
