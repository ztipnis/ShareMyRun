//
//  ButtonsView.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 12/6/15.
//  Copyright © 2015 Zachal. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class startButton:UIView {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        RunStyleKit.drawStartButton(rect)
    }
    
}

@IBDesignable
class pastRuns: UIView {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        RunStyleKit.drawPastRuns(rect)
    }
}

@IBDesignable
class nearbyRuns: UIView {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        RunStyleKit.drawNearbyRuns(rect)
    }
}