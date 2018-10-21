//
//  RangeDateClockSlider.swift
//  DateClockSlider
//
//  Created by 岩佐晃也 on 2018/10/21.
//

import UIKit

open class RangeDateClockSlider: DateClockSlider {
    
    public enum SelectedThumb {
        case startThumb
        case endThumb
        case none
        
        var isStart: Bool {
            return  self == SelectedThumb.startThumb
        }
        var isEnd: Bool {
            return  self == SelectedThumb.endThumb
        }
    }
    
    open var distance: CGFloat = -1 {
        didSet {
            assert(distance <= maximumValue - minimumValue, "The distance value is greater than distance between max and min value")
            endPointValue = startPointValue + distance
        }
    }
    
    open var startPointValue: CGFloat = 0.0 {
        didSet {
            guard oldValue != startPointValue else { return }
            
            if startPointValue < minimumValue {
                startPointValue = minimumValue
            }
            
            if distance > 0 {
                endPointValue = startPointValue + distance
            }
            
            setNeedsDisplay()
        }
    }
    
    override open var endPointValue: CGFloat {
        didSet {
            if oldValue == endPointValue && distance <= 0 {
                return
            }
            
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
            
            if distance > 0 {
                startPointValue = endPointValue - distance
            }
            
            setNeedsDisplay()
        }
    }
    
    fileprivate var selectedThumb: SelectedThumb = .none
    
    public let startView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        self.isExclusiveTouch = true
        
        self.addSubview(self.imageView)
        self.addSubview(self.endView)
        self.addSubview(self.startView)
        
        // MARK: なぜかimageViewずれてます
        self.imageView.frame = CGRect(x: bounds.midX - (bounds.width - self.thumbRadius * 2) / 2, y: bounds.midY - (bounds.height - self.thumbRadius  * 2) / 2 - 1, width: bounds.width - self.thumbRadius * 2 + 4, height: bounds.height - self.thumbRadius * 2 + 2)
        self.imageView.layer.cornerRadius = (bounds.width - self.thumbRadius * 2) / 2
        self.imageView.layer.masksToBounds = true
        
        self.endView.isUserInteractionEnabled = false
        self.endView.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        self.endView.layer.cornerRadius = self.thumbRadius
        moveThumb(toAngle: endPointValue * CGFloat(Double.pi * 2) - CGFloat(Double.pi / 2) + 0.2, thumb: .endThumb)
        
        self.startView.isUserInteractionEnabled = false
        self.startView.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        self.startView.layer.cornerRadius = self.thumbRadius
        moveThumb(toAngle: startPointValue * CGFloat(Double.pi * 2) - CGFloat(Double.pi / 2), thumb: .startThumb)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawSelectedArc(fromAngle: valueToAngle(self.startPointValue), toAngle: valueToAngle(self.endPointValue))
    }
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPosition = touch.location(in: self)
        
        var thumbValue: CGFloat
        
        if self.startView.frame.contains(touchPosition) {
            selectedThumb = .startThumb
            thumbValue = startPointValue
        } else if self.endView.frame.contains(touchPosition) {
            selectedThumb = .endThumb
            thumbValue = endPointValue
        } else {
            selectedThumb = .none
            return false
        }
        
        let startPoint = CGPoint(x: bounds.midX, y: 0)
        let value = newValue(from: thumbValue, touch: touchPosition, start: startPoint)
        
        changeValue(value)
        sendActions(for: .editingDidBegin)
        
        return true
    }
    
    public func getCurrentDateComponents(thumb: SelectedThumb) -> DateComponents {
        var value: CGFloat
        
        switch thumb {
        case .startThumb:
            value = self.startPointValue
        case .endThumb:
            value = self.endPointValue
        case .none:
            return DateComponents()
        }
        
        let jaLocale = Locale(identifier: "ja_JP")
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = jaLocale
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let dateComponents = DateComponents(calendar: calendar,
                                            hour: Int(value * 12),
                                            minute: Int(round((value * 12 - CGFloat(Int(value * 12))) * 2) * 30))
        
        return dateComponents
    }
    
    internal override func changeValue(_ value: CGFloat) {
        var pointValue: CGFloat
        
        switch selectedThumb {
        case .startThumb:
            pointValue = startPointValue
            startPointValue = value
        case .endThumb:
            pointValue = endPointValue
            endPointValue = value
        case .none:
            return
        }
        
        let roundedValue = round(value * numberOfDelimiters) / numberOfDelimiters
        let roundedEndPointValue = round(pointValue * numberOfDelimiters) / numberOfDelimiters
        if roundedValue != roundedEndPointValue {
            generator.impactOccurred()
        }
        
        moveThumb(toAngle: value * CGFloat(Double.pi * 2) - CGFloat(Double.pi / 2), thumb: selectedThumb)
    }
    
    internal func moveThumb(toAngle angle: CGFloat, thumb: SelectedThumb) {
        let circle = Circle(origin: CGPoint(x: bounds.midX, y: bounds.midY), radius: self.radius)
        let endPoint = DateClockSliderHelper.endPoint(fromCircle: circle, angle: angle)
        
        var view: UIView
        switch thumb {
        case .startThumb:
            view = self.startView
        case .endThumb:
            view = self.endView
        case .none:
            return
        }
        
        view.frame = CGRect(x: endPoint.x - self.thumbRadius, y: endPoint.y - self.thumbRadius, width: self.thumbRadius * 2, height: self.thumbRadius * 2)
    }
}
