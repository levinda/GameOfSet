//
//  SetGame.swift
//  TheGameOfSet
//
//  Created by Danil on 02.05.18.
//  Copyright © 2018 Danil. All rights reserved.
//

import Foundation

class SetGame {
    
    
    //MARK: Properties
    
    private(set) var cards = [Card]()
    private(set) var cardsOnTable = [Card]()
    private(set) var score = 0
    
    private var areCardsSet = false
    
    init(){
        
        for shape in Shape.allShapes{
            for color in Color.allColors{
                for fill in Fill.allFills{
                    for x in 1...3{
                        let card = Card(number: x, color: color, fill: fill, shape: shape)
                        cards.append(card)
                    }
                }
            }
        }
        //Draft 12 cards
        cards.radomize()
        for _ in 1...12{
            cardsOnTable.append(cards.removeLast())
        }
    }

    func checkSelectedCardsForSet(for cards: [Card]) -> Bool{
        
        var shapes = [Shape]()
        var colors = [Color]()
        var numbers = [Int]()
        var fills = [Fill]()
        
        for card in cards{
            if !shapes.contains(card.shape){
                shapes.append(card.shape)
            }
            if !colors.contains(card.color){
                colors.append(card.color)
            }
            if !numbers.contains(card.number){
                numbers.append(card.number)
            }
            if !fills.contains(card.fill){
                fills.append(card.fill)
            }
        }
        if (shapes.count != 2)&&(colors.count != 2)&&(numbers.count != 2)&&(fills.count != 2){
            
            for card in cards{
                if let indexOfSelectedCard = cardsOnTable.index(of: card){
                    cardsOnTable.remove(at: indexOfSelectedCard)
                    if self.cards.count > 0 {
                        cardsOnTable.insert(self.cards.removeLast(), at: indexOfSelectedCard)
                    }
                }
            }
            score += 3
            areCardsSet = true
            return areCardsSet
            
        }else{
            score -= 5
            areCardsSet = false
            return areCardsSet
            
        }
    }
    
    func removeCardsFromGameByCardIndexes(_ indexes:[Int]){
        for index in indexes{
            cardsOnTable.remove(at: index)
            if cards.count > 0{
            }
        }
    }
    
    func checkAllCards(for cards: [Card]) -> Bool{
        
        var shapes = [Shape]()
        var colors = [Color]()
        var numbers = [Int]()
        var fills = [Fill]()
        
        for card in cards{
            if !shapes.contains(card.shape){
                shapes.append(card.shape)
            }
            if !colors.contains(card.color){
                colors.append(card.color)
            }
            if !numbers.contains(card.number){
                numbers.append(card.number)
            }
            if !fills.contains(card.fill){
                fills.append(card.fill)
            }
        }
        if (shapes.count != 2)&&(colors.count != 2)&&(numbers.count != 2)&&(fills.count != 2){
            return true
        }else{
            return false
        }
    }

    func deal3MoreCards(){
        if (cards.count >= 3)&&(!areCardsSet){
            for _ in 1...3{
                cardsOnTable.append(cards.removeLast())
            }
        }
        areCardsSet = false
    }
    
    func IsThereASetOnTable() -> Bool{
        for firstCard in cardsOnTable{
            var secondCards = cardsOnTable
            secondCards.remove(at: secondCards.index(of: firstCard)!)
            for secondCard in secondCards{
                var thirdCards = secondCards
                thirdCards.remove(at: thirdCards.index(of: secondCard)!)
                for thirdCard in thirdCards{
                    if checkAllCards(for: [firstCard,secondCard,thirdCard]){
                        return true
                    }
                }
            }
        }
        return false
    }
    
}


extension Array{
    mutating func radomize(){
        for x in self.indices{
            self.insert(self.remove(at: x), at: self.count.arc4random)
        }
    }
}

extension Int {
    var arc4random: Int{
        if self > 0{
            return Int(arc4random_uniform(UInt32(self)))
        }else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        }else {
            return 0
        }
        
    }
}
