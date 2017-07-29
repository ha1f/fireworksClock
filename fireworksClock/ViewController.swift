//
//  ViewController.swift
//  fireworksClock
//
//  Created by はるふ on 2017/07/28.
//  Copyright © 2017年 はるふ. All rights reserved.
//

import UIKit

// http://d.hatena.ne.jp/shu223/20130315/1363298992
// https://developer.apple.com/documentation/quartzcore/caemitterlayer
// http://www.knowstack.com/swift-caemittercell-caemitterlayer-fireworks/
class FireworksView: UIView {
    
    static let particlesCount = 20000
    
    let emitterLayer = CAEmitterLayer()
    let sparkDelay: Float = 1.5
    var emitterCells: [CAEmitterCell] {
        return self.emitterLayer.emitterCells ?? []
    }
    
    /// returns circle image filled with specified color
    private static func generateCircleImage(with color: UIColor, size: CGSize = CGSize(width: 25, height: 25), inset: UIEdgeInsets = .zero) -> UIImage {
        let circleSize = CGSize(width: size.width - inset.left - inset.right, height: size.height - inset.top - inset.bottom)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(x: inset.left, y: inset.top), size: circleSize))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsPopContext()
        return image!
    }
    
    private func generateSparkCell(particle: UIImage, birthRate: Float) -> CAEmitterCell {
        let sparkCell = CAEmitterCell()
        sparkCell.contents = particle.cgImage
        sparkCell.emissionRange = CGFloat.pi * 2
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
    
    private func generateSparkCell(color: UIColor, birthRate: Float) -> CAEmitterCell {
        return generateSparkCell(particle: FireworksView.generateCircleImage(with: color), birthRate: birthRate)
    }
    
    private func generateBaseCell(birthRate: Float, cells: [CAEmitterCell], isColorful: Bool = false) -> CAEmitterCell {
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
        if isColorful {
            base.color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
            base.redRange = 0.9
            base.greenRange = 0.9
            base.blueRange = 0.9
        }
        return base
    }
    
    private func generateBaseCell(birthRate: Float, risingCell: CAEmitterCell, colors: [UIColor], isColorful: Bool = false) -> CAEmitterCell {
        let sparkRate = Float(FireworksView.particlesCount / colors.count)
        let cells = colors.map { color in
            generateSparkCell(color: color, birthRate: sparkRate)
        }
        return generateBaseCell(birthRate: birthRate, cells: [risingCell] + cells, isColorful: isColorful)
    }
    
    private func generateRisingCell(particle: UIImage = FireworksView.generateCircleImage(with: UIColor.white)) -> CAEmitterCell {
        let risingCell = CAEmitterCell()
        risingCell.contents = particle.cgImage
        risingCell.emissionLongitude = (4 * CGFloat.pi) / 2
        risingCell.emissionRange = CGFloat.pi / 7
        risingCell.scale = 0.2
        risingCell.velocity = 100
        risingCell.birthRate = 50
        risingCell.lifetime = self.sparkDelay
        risingCell.yAcceleration = 200
        risingCell.alphaSpeed = -0.7
        risingCell.scaleSpeed = -0.1
        risingCell.scaleRange = 0.1
        risingCell.beginTime = 0.01
        risingCell.duration = 0.9
        return risingCell
    }
    
    func resetEmitPosition() {
        // 下過ぎないように
        emitterLayer.emitterPosition = CGPoint(x: self.bounds.midX, y: min(self.bounds.maxY, 450))
    }
    

    func setup() {
        emitterLayer.emitterMode = kCAEmitterLayerAdditive
        
        let risingCell = self.generateRisingCell(particle: FireworksView.generateCircleImage(with: UIColor.red))
        
        // 花火うちあげ元
        let blueWhiteBase = generateBaseCell(birthRate: 0.4, risingCell: risingCell, colors: [.blue, .blue, .white, .blue])
        let redYellowBase = generateBaseCell(birthRate: 0.8, risingCell: risingCell, colors: [.red, .yellow, .red, .yellow])
        let greenBase = generateBaseCell(birthRate: 0.6, risingCell: risingCell, colors: [.green])
        let colorfulBase = generateBaseCell(birthRate: 1.2, risingCell: generateRisingCell(), colors: [.white], isColorful: true)
        
        self.emitterLayer.emitterCells = [redYellowBase, blueWhiteBase, greenBase, colorfulBase]
        self.layer.addSublayer(emitterLayer)
        resetEmitPosition()
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
        // 自動ロックしないように
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.fireworksView.resetEmitPosition()
    }

}

