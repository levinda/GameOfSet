//
//  ViewController.swift
//  TheGameOfSet
//
//  Created by Danil on 01.05.18.
//  Copyright © 2018 Danil. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    //MARK: GesturesRecognizers
    
    
    
    //MARK: Properties
    
    private var shapes = [Shape.triangle: CardShape.triangle,Shape.circle: CardShape.oval,Shape.square: CardShape.wave]
    private var colors = [Color.first: #colorLiteral(red: 0, green: 0.726098001, blue: 0, alpha: 1), .second: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), .third: #colorLiteral(red: 0.4170517325, green: 0, blue: 0.5548704267, alpha: 1)]
    private var fill = [Fill.none: CardFill.none ,Fill.striped: CardFill.stripped, Fill.full: CardFill.full]
    
    private var game = SetGame(){
        didSet{
            updateViewFromModel()
        }
    }
    
    @IBOutlet weak var cardDrawingView: UIView!
    
    
    private var cardViews = [CardView](){
        didSet{
            grid.cellCount = cardViews.count
            for cardIndex in cardViews.indices{
                let frame = grid[cardIndex]!
                cardViews[cardIndex].frame = frame.insetBy(dx: frame.width * 1/20, dy: frame.height * 1/20) ?? CGRect.zero
            }
        }
    }
    
    private var selectedCardViews = [CardView]()
    
    lazy private var grid = Grid(layout: Grid.Layout.aspectRatio(56/87), frame: cardDrawingView.frame)
    
    @IBOutlet weak var testCardView: CardView!
    
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
            }
        }
    }
    
   
    
    //MARK: Functions
    
    private func  makeCardAndRepresentingViewEqual(cardView: CardView, card: Card){
        cardView.color = colors[card.color]!
        cardView.fill = fill[card.fill]!
        cardView.number = card.number
        cardView.shape = shapes[card.shape]!
    }
    
    
    private func updateViewFromModel(){
        for cardIndex in game.cardsOnTable.indices{
            if cardIndex + 1 < cardViews.count{
                 makeCardAndRepresentingViewEqual(cardView: cardViews[cardIndex], card: game.cards[cardIndex])
            }else{
                let newCard = CardView()
                 let cardSelectGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectCard(recognizer:)))
                newCard.isOpaque = false
                makeCardAndRepresentingViewEqual(cardView: newCard, card: game.cardsOnTable[cardIndex])
                newCard.addGestureRecognizer(cardSelectGestureRecognizer)
                cardSelectGestureRecognizer.delegate = self
                view.addSubview(newCard)
                cardViews.append(newCard)
                
            }
        }
    }
    
    override func viewDidLoad() {
        updateViewFromModel()
    }
    
    
    //MARK: Selectors
    
    @objc func selectCard(recognizer : UITapGestureRecognizer){
        switch recognizer.state{
        case .ended:
            if let sender = recognizer.view as? CardView{
                    
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1,
                                                                   delay: 0,
                                                                   options: [UIView.AnimationOptions.allowUserInteraction,.curveEaseInOut,.beginFromCurrentState] ,
                                                                   animations: {sender.centerScaleBy(factor: sender.isSelected ? 1/0.8 : 0.8 ) })
                    sender.isSelected = sender.isSelected ? false : true
                }

        default: break
        }
    }
    
    //MARK: Actions
    
    
}


extension CGRect{
    func scaledBy(factor : CGFloat) -> CGRect{
        let rect = CGRect(origin: self.origin, size: CGSize(width: self.width * factor, height: self.height * factor))
        return rect
    }
}

extension UIView{
    func centerScaleBy(factor: CGFloat){
        let centerPoint = self.center
        self.frame = self.frame.scaledBy(factor: factor)
        self.center = centerPoint
        
    }
    
    func scaleBy(factor:CGFloat){
        self.frame = self.frame.scaledBy(factor: factor)
    }
}

