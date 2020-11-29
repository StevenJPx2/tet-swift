//
//  DataStructures.swift
//  Tet
//
//  Created by Steven Johns on 1/29/19.
//  Copyright © 2019 Steven Johns. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

enum Failure: Error {
    case functionfailed(functionName: String)
}

struct Reminder: Codable {
    let description: String
    var time: Date
    var isPaused = false
    var isRepeatable = false
    var isArchived = false
    var stringTime: String {
        get {
            let date = DateFormatter()
            date.dateStyle = .long
            date.timeStyle = .long
            return date.string(from: time)
        }
    }
    var comparedTime: Double {
        get {
            return Date().timeIntervalSince(time)
        }
    }
    var comparedTimeInHours: Int {
        get {
            return Int(round((86400 - Date().timeIntervalSince(time))/3600))
        }
    }
    
    var pausedDifferenceInTime = 0.00
    
    init(description: String, time: Date = Date()) {
        self.description = description
        self.time = time
    }
    
    mutating func repeatTask(){
        if isRepeatable {
            if comparedTime <= 0 {
                time = Date(timeIntervalSinceNow: -comparedTime)
            }
        }
    }
    mutating func pauseTask(_ initialised: Bool) {
        if isPaused {
            if initialised {
                pausedDifferenceInTime = -comparedTime
            }
            time = Date(timeIntervalSinceNow: pausedDifferenceInTime)
            print("paused Difference: \(pausedDifferenceInTime)")
        }
    }
    
    mutating func togglePauseFlag() -> Bool {
        isPaused = !isPaused
        return true
    }
    
    mutating func toggleRepeatFlag() -> Bool {
        isRepeatable = !isRepeatable
        return true
    }
    
    mutating func toggleArchiveFlag() -> Bool {
        isArchived = !isArchived
        return true
    }
    
    mutating func returnAllFlags() -> (repeatFlag: Bool, pauseFlag: Bool, archiveFlag: Bool) {
        return (isRepeatable, isPaused, isArchived)
    }
    
}

@IBDesignable final class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.init(rgb: 0xFAD961)
    @IBInspectable var endColor: UIColor = UIColor.init(rgb: 0xF9A13E)
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradient()
    }
    
    private func setupGradient() {
        let gradient = self.layer as! CAGradientLayer
        gradient.colors = [startColor.cgColor, endColor.cgColor]
    }
    
}
