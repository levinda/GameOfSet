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
    
    var selectingFeedbackGenerator = UIImpactFeedbackGenerator()
    @IBOutlet weak var cardDrawingView: UIView!
    
    //MARK: Properties
    
    private var shapes = [Shape.triangle: CardShape.triangle,Shape.circle: CardShape.oval,Shape.square: CardShape.wave]
    private var colors = [Color.first: #colorLiteral(red: 0, green: 0.726098001, blue: 0, alpha: 1), .second: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), .third: #colorLiteral(red: 0.4170517325, green: 0, blue: 0.5548704267, alpha: 1)]
    private var fill = [Fill.none: CardFill.none ,Fill.striped: CardFill.stripped, Fill.full: CardFill.full]
    
    private var game = SetGame(){
        didSet{
            updateViewFromModel()
        }
    }
    
    
    private var newCardViews = [CardView]()
    
     private var cardViews = [CardView](){
        didSet{
            grid.cellCount = cardViews.count
            
            for cardIndex in cardViews.indices{
                let currentCardView = cardViews[cardIndex]
                let initialFrame = grid[cardIndex]!
                let frame = initialFrame.insetBy(dx: initialFrame.width * 1/20, dy: initialFrame.height * 1/20)
                
                if newCardViews.contains(currentCardView){
                    UIView.animateKeyframes(withDuration: 0.5  , delay: 0.1 + Double(newCardViews.firstIndex(of: currentCardView)!)/10 , animations: {  currentCardView.frame = frame})
                }else{
                    UIView.animate(withDuration: 0.5, animations: {currentCardView.frame = frame})
                }
            }
            newCardViews = []
        }
    }
    
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
    
    /// Card representing view properties according to card model properties
    private func  makeCardAndRepresentingViewEqual(cardView: CardView, card: Card){
        cardView.color = colors[card.color]!
        cardView.fill = fill[card.fill]!
        cardView.number = card.number
        cardView.shape = shapes[card.shape]!
    }
    
    
    private func updateViewFromModel(){
        for cardIndex in game.cardsOnTable.indices{
            grid.cellCount = game.cardsOnTable.count
            if cardIndex + 1 <= cardViews.count{
                 makeCardAndRepresentingViewEqual(cardView: cardViews[cardIndex], card: game.cardsOnTable[cardIndex])
            }else{
                let newCard = CardView()
                let cardSelectGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectCard(recognizer:)))
                newCard.addGestureRecognizer(cardSelectGestureRecognizer)
                     cardSelectGestureRecognizer.delegate = self
                newCard.isOpaque = false
                
                newCard.index = cardIndex
                makeCardAndRepresentingViewEqual(cardView: newCard, card: game.cardsOnTable[cardIndex])
                self.view.addSubview(newCard)
                newCardViews.append(newCard)
            }
        }
        cardViews += newCardViews
    }

    
    //MARK: Selectors
    
    @objc func selectCard(recognizer : UITapGestureRecognizer){
        switch recognizer.state{
        case .ended:
            if let sender = recognizer.view as? CardView{
                    selectingFeedbackGenerator.prepare()
                    selectingFeedbackGenerator.impactOccurred()
                    animateCardSelection(for: sender)
                    sender.isSelected = sender.isSelected ? false : true
        
            }
        default: break
        }
    }
    
    @objc func deal3MoreCards(recognizer: UISwipeGestureRecognizer){
        switch recognizer.state{
        case .ended:
            
            game.deal3MoreCards()
            updateViewFromModel()
        default: break
        }
    }
    
    //MARK: Animations
    
    func animateCardSelection(for cardView: CardView){
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1,
                                                       delay: 0,
                                                       options: [UIView.AnimationOptions.allowUserInteraction,.curveEaseInOut,.beginFromCurrentState] ,
                                                       animations: {cardView.centerScaleBy(factor: cardView.isSelected ? 1/0.8 : 0.8 )
                                                        cardView.alpha = cardView.isSelected ? 1 : 0.8
                                                        
        })
    }
    
    
    override func viewDidLoad() {
        updateViewFromModel()
        selectingFeedbackGenerator.prepare()
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.deal3MoreCards(recognizer:)))
        downSwipeGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(downSwipeGestureRecognizer)
        downSwipeGestureRecognizer.delegate = self
    }
    
    
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

