//
//  ViewController.swift
//  fireworksClock
//
//  Created by はるふ on 2017/07/28.
//  Copyright © 2017年 はるふ. All rights reserved.
//

import UIKit

class FireworksView: UIView {
    
    func configure() {
        let layer = CAEmitterLayer()
        
        
        
        self.layer.addSublayer(layer)
    }
    
}

class ViewController: UIViewController {

    @IBOutlet weak var fireworksView: FireworksView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var updateTimer: Timer!
    lazy var dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        
        updateTimer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let unwrappedSelf = self else {
                return
            }
            let now = Date()
            unwrappedSelf.timeLabel.text = unwrappedSelf.dateFormatter.string(from: now)
        }
        updateTimer.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        updateTimer.invalidate()
    }

}

