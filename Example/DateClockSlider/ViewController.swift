//
//  ViewController.swift
//  DateClockSlider
//
//  Created by kot10n5tn on 10/20/2018.
//  Copyright (c) 2018 kot10n5tn. All rights reserved.
//

import UIKit
import DateClockSlider

class ViewController: UIViewController {
    
    private lazy var dateClockSlider = DateClockSlider(frame: CGRect(x: self.view.bounds.midX - 160, y: self.view.bounds.midY - 160, width: 320, height: 320))
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = .white
        self.view.addSubview(dateClockSlider)
        
        self.view.addSubview(self.timeLabel)
        
        self.timeLabel.frame = CGRect(x: self.view.bounds.midX - 160, y: self.view.bounds.midY + 240, width: 320, height: 20)
        
        dateClockSlider.addTarget(self, action: #selector(onChanged), for: .editingDidBegin)
        dateClockSlider.addTarget(self, action: #selector(onChanged), for: .valueChanged)
    }
    
    @objc private func onChanged(sender: UIControl) {
        guard let dateClockSlider = sender as? DateClockSlider else {
            return
        }
        
        self.timeLabel.text = dateFormatter.string(from: dateClockSlider.getCurrentDateComponents().date!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

