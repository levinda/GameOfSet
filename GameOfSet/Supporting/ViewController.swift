//
//  ViewController.swift
//  TheGameOfSet
//
//  Created by Danil on 01.05.18.
//  Copyright © 2018 Danil. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    //MARK: Properties
    
    private var shapes = [Shape.triangle: "▲",Shape.circle:"●",Shape.square: "■"]
    private var colors = [Color.first: UIColor.green, .second: .red, .third: .purple]
    private var fill = [Fill.none: 10,Fill.striped: -10, Fill.full:0]
    
    private var game = SetGame()
    
    private var grid = Grid(layout: Grid.Layout.aspectRatio(0.5))
    
    @IBOutlet var buttons: [UIButton]!{
        didSet{
            for button in buttons{
                button.layer.borderWidth = 1
                button.layer.cornerRadius = 8
            }
        }
    }
    
    
    
    @IBOutlet weak var gameScoreLabel: UILabel!
    
    @IBOutlet weak var cardCountButton: UIButton!
    
    
    private(set) var selectedButton = [UIButton](){
        didSet{
            for button in oldValue{
                button.layer.borderWidth = 1.0
                button.layer.borderColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
            }
            for button in selectedButton{
                button.layer.borderWidth = 3.5
                button.layer.borderColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
            }
            if selectedButton.count == 3{
                var selectedCards = [Card]()
                for button in selectedButton{
                    selectedCards.append(game.cardsOnTable[button.tag])
                }
                makeSelectedCardsSetOrNot(state: game.checkSelectedCardsForSet(for: selectedCards))
            }
        }
    }
    
    var areCardsAMatch: Bool = false
    
    var gameScore: Int {
        set{
            gameScoreLabel.text = "Score: \(newValue)"
        }
        get{
            return game.score
        }
    }
    
    
    //MARK: Functions
    
    private func updateTableFromModel(){
        gameScore = game.score
        for button in buttons{
            makeButtonRepresentTheModel(button)
        }
        cardCountButton.setTitle("Cards left: \(game.cards.count + game.cardsOnTable.count)", for: .normal)
        
    }
    
    
    private func makeButtonRepresentTheModel(_ button: UIButton){
        
        button.isHidden = false
        
        if button.tag < game.cardsOnTable.count{
            let representedCard = game.cardsOnTable[button.tag]
            
            var title = ""
            for _ in 1...representedCard.number{
                title += shapes[representedCard.shape]!
            }
            
            let attributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.strokeColor : colors[representedCard.color]!,
                NSAttributedString.Key.strokeWidth : fill[representedCard.fill]!,
                ]
            
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            button.tintColor = colors[representedCard.color]
            button.setAttributedTitle(attributedTitle, for: .normal)
            if representedCard.fill == .striped{
                button.setTitle(title, for: .normal)
                button.tintColor = colors[representedCard.color]!.withAlphaComponent(0.3)
            }
            
        }else{
            button.isHidden = true
        }
    }
    
    private func makeSelectedCardsSetOrNot(state: Bool){
        for button in selectedButton{
            button.layer.borderColor = state ? #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) : #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
        areCardsAMatch = state
        gameScoreLabel.text = "Score: \(game.score)"
    }
    
    //MARK: Actions
    
    @IBAction func touchCard(_ sender: UIButton) {
        
        if selectedButton.count != 3{
            if let indexOfSelectedCard = selectedButton.index(of: sender){
                selectedButton.remove(at: indexOfSelectedCard)
            }else{
                selectedButton.append(sender)
            }
        }else{
            if (areCardsAMatch == true)&&(selectedButton.contains(sender)){
                updateTableFromModel()
                selectedButton = []
            }else if areCardsAMatch != true{
                selectedButton = [sender]
            }
        }
        
    }
    
    @IBAction func deal3MoreCards(_ sender: UIButton) {
        print(game.IsThereASetOnTable())
        var openedCardCounter = 0
        for card in buttons{
            if !card.isHidden{
                openedCardCounter += 1
            }
        }
        if openedCardCounter != 24{
            game.deal3MoreCards()
            updateTableFromModel()
        }
    }
    
    @IBAction func startNewGame(_ sender: UIButton) {
        selectedButton = []
        game = SetGame()
        updateTableFromModel()
        gameScore = game.score
    }
    
}
