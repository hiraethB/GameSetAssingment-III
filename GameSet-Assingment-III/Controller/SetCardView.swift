//
//  SetCardView.swift
//  GameSet_Assingment3
//
//  Created by Борис Винник on 31.03.2018.
//  Copyright © 2018 GRIAL. All rights reserved.
//

import UIKit

class SetCardView: UIView {
    
    
    var number = 0 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var color: UIColor = #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1) { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var symbol = "oval" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var fill = "striped" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    func layerState() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = ratioLineWidth*2
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        UIColor.white.setFill()
        roundedRect.fill()
        guard symbol != "squiggle" else { return drawSquiggle()}
        symbol == "oval" ? drawOval(): drawDiamond()
    }
    
    private func drawDiamond() {
        let path = UIBezierPath()
        path.move(to: origin)
        path.addLine(to: origin.offsetBy(dx: -ratioWidth/2, dy: ratioHeight/2))
        path.addLine(to: origin.offsetBy(dx: 0, dy: ratioHeight))
        path.addLine(to: origin.offsetBy(dx: ratioWidth/2, dy: ratioHeight/2))
        path.close()
        drawCard(with: path)
    }
    
    private func drawOval() {
        let path = UIBezierPath()
        let radius = ratioHeight*0.45
        path.addArc(withCenter: origin.offsetBy(dx: -ratioWidth*0.28, dy: radius), radius: radius,
                    startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi*1.5, clockwise: true)
        path.addLine(to: origin.offsetBy(dx: ratioWidth*0.28, dy: 0))
        path.addArc(withCenter: origin.offsetBy(dx: ratioWidth*0.28, dy: radius), radius: radius,
                    startAngle: CGFloat.pi*1.5, endAngle: CGFloat.pi*0.5, clockwise: true)
        path.close()
        drawCard(with: path)
    }
    
    private func drawSquiggle() {
        let leftPath = UIBezierPath()
        leftPath.move(to: origin.offsetBy(dx: 0, dy: ratioHeight*0.85))
        leftPath.addQuadCurve(to: origin.offsetBy(dx: -ratioWidth*0.32, dy: ratioHeight*0.9),
                              controlPoint: controlPointQuad)
        leftPath.addCurve(to: origin.offsetBy(dx: 0, dy: ratioHeight*0.15),
                          controlPoint1: cubicControlPoint1, controlPoint2: cubicControlPoint2)
        let rightPath = UIBezierPath(cgPath: leftPath.cgPath)
        rightPath.apply(CGAffineTransform.identity.rotated(by: CGFloat.pi))
        rightPath.apply(CGAffineTransform.identity.translatedBy(x: bounds.width, y: bounds.height))
        leftPath.append(rightPath)
        drawCard(with: leftPath)
    }
    
    private func drawCard(with path: UIBezierPath) {
        path.lineWidth = ratioLineWidth
        color.setStroke()
        color.setFill()
        if number != 1 {
            // symbol at center
            if fill == "striped" {
                strip(path: path)
            }
            fill == "solid" ? path.fill() : path.stroke()
        }
        if number != 0 {
            // symbol down
            path.apply(CGAffineTransform.identity.translatedBy(x: 0, y: CGFloat(number)*interval/2))
            if fill == "striped" {
                strip(path: path)
            }
            fill == "solid" ? path.fill() : path.stroke()
            // symbol up
            path.apply(CGAffineTransform.identity.translatedBy(x: 0, y: -CGFloat(number)*interval))
            if fill == "striped" {
                strip(path: path)
            }
            fill == "solid" ? path.fill() : path.stroke()
        }
    }
    
    private func strip(path: UIBezierPath) {
        UIGraphicsGetCurrentContext()?.saveGState()
        path.addClip()
        let stripe = UIBezierPath()
        let  dashedLine = [ ratioLineWidth/2, ratioLineWidth]
        stripe.setLineDash(dashedLine, count: dashedLine.count, phase: 0)
        stripe.lineWidth = bounds.height
        stripe.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
        stripe.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        stripe.stroke()
        UIGraphicsGetCurrentContext()?.restoreGState()
    }
}

extension SetCardView {
    private struct SizeRatio {
        static let heightToBoundsHeight: CGFloat = 0.2
        static let widthToBoundsWidth: CGFloat = 0.68
        static let lineWidthToBoundsWidth: CGFloat = 0.04
        static let cornerRadiusToBoundsHeight: CGFloat = 0.08
    }
    
    private var ratioHeight: CGFloat {
        return bounds.height * SizeRatio.heightToBoundsHeight
    }
    
    private var ratioWidth: CGFloat {
        return bounds.width * SizeRatio.widthToBoundsWidth
    }
    
    private var interval: CGFloat {
        return bounds.size.height * (SizeRatio.heightToBoundsHeight
            + SizeRatio.cornerRadiusToBoundsHeight)
    }
    
    private var origin: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY - ratioHeight/2)
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private var ratioLineWidth: CGFloat {
        return bounds.width * SizeRatio.lineWidthToBoundsWidth
    }
    
    private var controlPointQuad: CGPoint {
        return CGPoint(x: bounds.width*0.35, y: bounds.height*0.55)
    }
    
    private var cubicControlPoint1: CGPoint {
        return CGPoint(x: bounds.width*0.06, y: bounds.height*0.7)
    }
    
    private var cubicControlPoint2: CGPoint {
        return CGPoint(x: bounds.width*0.06, y: bounds.height*0.3)
    }
}
extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}

