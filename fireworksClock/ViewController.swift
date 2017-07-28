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
    
    private static func circleImage(color: UIColor) -> UIImage {
        let imageSize = CGSize(width: 25, height: 25)
        let margin: CGFloat = 0
        let circleSize = CGSize(width: imageSize.width - margin * 2, height: imageSize.height - margin * 2)
        UIGraphicsBeginImageContext(imageSize)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(x: margin, y: margin), size: circleSize))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsPopContext()
        return image!
    }
    
    func setup() {
        emitterLayer.emitterPosition = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
        emitterLayer.emitterMode = kCAEmitterLayerAdditive
        
        let sparkDelay: Float = 1.5
        
        // 上昇中のパーティクルの発生源
        let risingCell = CAEmitterCell()
        risingCell.contents = FireworksView.circleImage(color: UIColor.red).cgImage
        risingCell.emissionLongitude = (4 * CGFloat.pi) / 2
        risingCell.emissionRange = CGFloat.pi / 7
        risingCell.scale = 0.2
        risingCell.velocity = 100
        risingCell.birthRate = 50
        risingCell.lifetime = sparkDelay
        risingCell.yAcceleration = 200
        risingCell.alphaSpeed = -0.7
        risingCell.scaleSpeed = -0.1
        risingCell.scaleRange = 0.1
        risingCell.beginTime = 0.01
        risingCell.duration = 0.9
        
        // 破裂後
        let generateSparkCell = { (particle: UIImage, birthRate: Float) -> CAEmitterCell in
            let sparkCell = CAEmitterCell()
            sparkCell.contents = particle.cgImage
            sparkCell.emissionRange = 2 * CGFloat.pi
            sparkCell.birthRate = birthRate
            sparkCell.scale = 0.2
            sparkCell.velocity = 130
            sparkCell.lifetime = 2.0
            sparkCell.lifetimeRange = 0.4
            sparkCell.yAcceleration = 80
            sparkCell.beginTime = CFTimeInterval(sparkDelay)
            sparkCell.duration = 0.1
            sparkCell.alphaSpeed = -0.1
            sparkCell.scaleSpeed = -0.1
            return sparkCell
        }
        let redSparkCell = generateSparkCell(FireworksView.circleImage(color: UIColor.red), 2000)
        let yellowSparkCell = generateSparkCell(FireworksView.circleImage(color: UIColor.yellow), 2000)
        let blueSparkCell = generateSparkCell(FireworksView.circleImage(color: UIColor.blue), 2000)
        let whiteSparkCell = generateSparkCell(FireworksView.circleImage(color: UIColor.white), 2000)
        let greenSparkCell8000 = generateSparkCell(FireworksView.circleImage(color: UIColor.green), 8000)
        
        let generateBaseCell = { (birthRate: Float, cells: [CAEmitterCell]) -> CAEmitterCell in
            let base = CAEmitterCell()
            base.emissionLongitude = -CGFloat.pi / 2
            base.emissionLatitude = 0
            base.emissionRange = CGFloat.pi / 5
            base.lifetime = 2.0
            base.birthRate = birthRate
            base.velocity = 400
            base.velocityRange = 50
            base.yAcceleration = 300
            base.emitterCells = cells
            return base
        }
        
        // 花火うちあげ元（花火玉の設定）
        let blueWhiteBase = generateBaseCell(0.4, [risingCell, blueSparkCell, blueSparkCell, whiteSparkCell, blueSparkCell])
        let redYellowBase = generateBaseCell(1.1, [risingCell, redSparkCell, yellowSparkCell, redSparkCell, yellowSparkCell])
        let greenBase = generateBaseCell(0.6, [risingCell, greenSparkCell8000])
        
        // redYellowBaseはemitterLayerから発生させる
        self.emitterLayer.emitterCells = [redYellowBase, blueWhiteBase, greenBase]
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

