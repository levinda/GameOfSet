//
//  SetCard.swift
//  TheGameOfSet
//
//  Created by Danil on 03.05.18.
//  Copyright © 2018 Danil. All rights reserved.
//

import Foundation


struct Card: Equatable, Hashable{
    
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        if (lhs.shape == rhs.shape)&&(lhs.color == rhs.color)&&(lhs.fill == rhs.fill)&&(lhs.number == rhs.number){
            return true
        }else{
            return false
        }
    }
    
    
    let number: Int
    let color: Color
    let fill: Fill
    let shape: Shape
    
}


enum Color{
    
    case first
    case second
    case third
    
    static let allColors = [Color.first,.second,.third]
}

enum Fill {
    
    case none
    case striped
    case full
    
    static let allFills = [Fill.none,.striped,.full]
}

enum Shape{
    
    case triangle
    case circle
    case square
    
    static let allShapes = [Shape.triangle,.circle,.square]
}
