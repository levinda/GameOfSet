//
//  CardView.swift
//  GameOfSet
//
//  Created by Danil on 12/09/2018.
//  Copyright © 2018 Danil. All rights reserved.
//

import UIKit


@IBDesignable class CardView: UIView {
    
    
    @IBInspectable var number: Int = 1
    @IBInspectable var color: UIColor = .purple
    var shape: CardShape = .wave
    var fill: CardFill = .stripped
    
    
    
    
    private func pathForOvals(for number: Int) -> UIBezierPath {
        
        let ovalHeight = dimentions.ovalHeight * bounds.height
        let ovalGap = dimentions.ovalGap * bounds.height
        let ovalCentralPart = dimentions.ovalCentralPart * bounds.width
        
        let marginFromTop = (bounds.height - CGFloat(number) * ovalHeight - CGFloat(number-1)*ovalGap)/2
        let marginFromSide = (bounds.width - ovalCentralPart)/2
        var startingPoint = CGPoint(x: marginFromSide, y: marginFromTop)
        
        let path = UIBezierPath()
        for _ in 1...number{
            path.move(to:startingPoint)
            var currentPoint = startingPoint
            currentPoint = currentPoint + (ovalCentralPart,0)
            path.addLine(to: currentPoint)
            path.addArc(withCenter: currentPoint + (0,ovalHeight/2) , radius: ovalHeight/2, startAngle: -CGFloat.pi/2 , endAngle: CGFloat.pi/2 , clockwise: true)
            currentPoint = currentPoint + (0,ovalHeight)
            currentPoint = currentPoint + (-ovalCentralPart,0)
            path.addLine(to: currentPoint)
            path.move(to: startingPoint)
            path.addArc(withCenter: currentPoint + (0,-ovalHeight/2) , radius: ovalHeight/2, startAngle: -CGFloat.pi/2 , endAngle: CGFloat.pi/2 , clockwise: false)
            
            startingPoint = startingPoint + (0,ovalHeight + ovalGap)
        }
        return path
    }
    
    private func pathForTriangales() -> UIBezierPath {
        
        let height  = dimentions.triangleHeight * bounds.height
        let width = dimentions.trinalgeWidth * bounds.width
        let gap = dimentions.triangleGap * bounds.height
        let path = UIBezierPath()
        
        let marginFromTop = (bounds.height - CGFloat(number) * height - CGFloat(number-1)*gap)/2
        var startingPoint = CGPoint(x: bounds.maxX/2, y: marginFromTop)
        for _ in 1...number{
            path.move(to: startingPoint)
            var currentPoint = startingPoint
            currentPoint = currentPoint + (width/2,height/2)
            path.addLine(to: currentPoint)
            currentPoint = currentPoint + (-width/2,height/2)
            path.addLine(to: currentPoint)
            currentPoint = currentPoint + (-width/2,-height/2)
            path.addLine(to: currentPoint)
            path.addLine(to: startingPoint)
            startingPoint = startingPoint + (0,height + gap)
        }
        return path
        
    }
    
    /// creating a path for waves in self.bounds
    private func pathForWaves() -> UIBezierPath{
    
        let height = dimentions.waveHeightToHeight * bounds.height
        let gap = dimentions.waveGapToHeight * bounds.height
        let marginFromSide = bounds.width * dimentions.waveStartingPointOffset
        let marginFromTop = (bounds.height - CGFloat(number) * height - CGFloat(number-1)*gap)/2
        
        //coordinates from grpahic software
        let coordinatesForCurve: [(CGFloat,CGFloat)] = [(414,242),(473.545532,207.060059),(480.098299,428.778325),(299.598299,388.278325),(208.098299,350.278325),(194.5,388.278325), (145,410),(83.5,418),(87.4017013,182.721675),(269,261),(332.61929,288.423228),(353.5,277.5),(414,242)]
        // make coordinates proportoinal for current bounds
        let scaledCoordinates = coordinatesForCurve.map{return  CGPoint(point: ($0.0 * bounds.width/560, $0.1 * bounds.height/870))}
        
        // defining changing in coordinates from first point
        let scaledToFirstPoint = scaledCoordinates.map{return $0 - scaledCoordinates.first!}
        print(scaledToFirstPoint)
        let step1 = Array<CGPoint>(scaledToFirstPoint[1...3])
        let step2 = Array<CGPoint>(scaledToFirstPoint[4...6])
        let step3 = Array<CGPoint>(scaledToFirstPoint[7...9])
        let step4 = Array<CGPoint>(scaledToFirstPoint[10...12])
        let steps = [step1,step2,step3,step4]
    
        let path = UIBezierPath()
        var startingPoint = CGPoint(x: marginFromSide, y: marginFromTop)
        
        for _ in 1...number{
            path.move(to:startingPoint)
            for step in steps{
                path.addCurve(to: startingPoint + step[2],controlPoint1: startingPoint +  step[0], controlPoint2:  startingPoint + step[1])
            }
            startingPoint = startingPoint + (0,height+gap)
        }
        return path
    }
    
    private func pathForStripes() -> UIBezierPath{
        let path = UIBezierPath()
        for x in stride(from: 0, to: bounds.maxX, by: bounds.width * dimentions.stripingStepToWidth){
            path.move(to: CGPoint(x: x,y:0))
            path.addLine(to: CGPoint(x: x,y:bounds.maxY) )
        }
        return path
    }
    
    override func draw(_ rect: CGRect) {
        
        let pathForCardBounds = UIBezierPath(roundedRect: bounds, cornerRadius: dimentions.cornerRadius * bounds.height)
        UIColor.white.setFill()
        pathForCardBounds.fill()
        
        color.set()
        var path = UIBezierPath()
        switch shape{
        case .oval: path = pathForOvals(for: number)
        case .triangle: path = pathForTriangales()
        case .wave: path = pathForWaves()
        }
        switch fill {
        case .none: path.stroke()
            case .stripped:
                path.lineWidth = 3.0
                path.stroke()
                path.addClip()
                pathForStripes().lineWidth = 0.25
                pathForStripes().stroke()
        case .full: path.fill()
        }
        
    }
    
}

enum CardShape{
    case oval
    case triangle
    case wave
}
enum CardFill{
    case none
    case stripped
    case full
}

struct dimentions{
    static let cornerRadius: CGFloat = 5/87
    //Oval
    static let ovalHeight: CGFloat = 17/87
    static let ovalWidth: CGFloat =  37/56
    static let ovalGap: CGFloat = 7/87
    static let ovalCentralPart: CGFloat = 20/56
    //Trinagle
    static let triangleHeight: CGFloat = 18/87
    static let trinalgeWidth:CGFloat = 40/56
    static let triangleGap: CGFloat = 9/87
    //Wave
    static let waveStartingPointOffset: CGFloat = 41/56
    static let waveHeightToHeight: CGFloat = 17/87
    static let waveGapToHeight: CGFloat = 43/870
    //Stripes
    static let stripingStepToWidth: CGFloat = 1/56
    //Line
}

extension CGPoint{
    static func +(rhs:CGPoint, lhs:CGPoint) -> CGPoint{
        return CGPoint(x: rhs.x + lhs.x, y: rhs.y+lhs.y)
    }
    static func -(rhs:CGPoint, lhs:CGPoint) -> CGPoint{
        return CGPoint(x: rhs.x - lhs.x, y: rhs.y-lhs.y)
    }
    static func +(rhs:CGPoint, lhs:(CGFloat,CGFloat)) -> CGPoint{
        return CGPoint(x: rhs.x + lhs.0, y: rhs.y+lhs.1)
    }
    
    init(point: (CGFloat,CGFloat)){
        self.init()
        self.x = point.0
        self.y = point.1
    }
}
