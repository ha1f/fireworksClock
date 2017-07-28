//
//  ViewController.swift
//  fireworksClock
//
//  Created by はるふ on 2017/07/28.
//  Copyright © 2017年 はるふ. All rights reserved.
//

import UIKit
import QuartzCore

// http://d.hatena.ne.jp/shu223/20130315/1363298992
// https://developer.apple.com/documentation/quartzcore/caemitterlayer
class FireworksView: UIView {
    
    let emitterLayer = CAEmitterLayer()
    lazy var particleImage: UIImage = {
        let imageSize = CGSize(width: 50, height: 50)
        let margin: CGFloat = 0
        let circleSize = CGSize(width: imageSize.width - margin * 2, height: imageSize.height - margin * 2)
        UIGraphicsBeginImageContext(imageSize)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.red.cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(x: margin, y: margin), size: circleSize))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsPopContext()
        return image!
    }()
    
    func setup() {
        emitterLayer.emitterPosition = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
        emitterLayer.emitterMode = kCAEmitterLayerAdditive
        
        let baseCell = CAEmitterCell()
        baseCell.emissionLongitude = -CGFloat.pi / 2
        baseCell.emissionLatitude = 0
        baseCell.emissionRange = CGFloat.pi / 5
        baseCell.lifetime = 2.0
        baseCell.birthRate = 0.5
        baseCell.velocity = 400
        baseCell.velocityRange = 50
        baseCell.yAcceleration = 300
        // パーティクルの色
        baseCell.color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5).cgColor
        baseCell.redRange   = 0.5
        baseCell.greenRange = 0.5
        baseCell.blueRange  = 0.5
        baseCell.alphaRange = 0.5
        
        // 上昇中のパーティクルの発生源
        let risingCell = CAEmitterCell()
        risingCell.contents = particleImage.cgImage
        risingCell.emissionLongitude = (4 * CGFloat.pi) / 2
        risingCell.emissionRange = CGFloat.pi / 7
        risingCell.scale = 0.3
        risingCell.velocity = 100
        risingCell.birthRate = 50
        risingCell.lifetime = 1.5
        risingCell.yAcceleration = 350
        risingCell.alphaSpeed = -0.7
        risingCell.scaleSpeed = -0.1
        risingCell.scaleRange = 0.1
        risingCell.beginTime = 0.01
        risingCell.duration = 0.7
        
        // 破裂後に飛散するパーティクルの発生源
        let sparkCell = CAEmitterCell()
        sparkCell.contents = particleImage.cgImage
        // パーティクルを発生する角度の範囲
        sparkCell.emissionRange = 2 * CGFloat.pi
        // １秒間に生成するパーティクルの数
        sparkCell.birthRate = 8000
        sparkCell.scale = 0.2
        sparkCell.velocity = 130
        // パーティクルが発生してから消えるまでの時間(s)
        sparkCell.lifetime = 2.0
        sparkCell.yAcceleration = 80
        sparkCell.beginTime = CFTimeInterval(risingCell.lifetime)
        sparkCell.duration = 0.1
        sparkCell.alphaSpeed = -0.1
        sparkCell.scaleSpeed = -0.1
        
        // baseCellからrisingCellとsparkCellを発生させる
        baseCell.emitterCells = [risingCell, sparkCell]
        
        // baseCellはemitterLayerから発生させる
        self.emitterLayer.emitterCells = [baseCell]
        self.layer.addSublayer(emitterLayer)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var fireworksView: FireworksView! {
        didSet {
            fireworksView.setup()
        }
    }
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

