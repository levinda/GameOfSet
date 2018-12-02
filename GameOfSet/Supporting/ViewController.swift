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
    
    lazy private var grid = Grid(layout: Grid.Layout.aspectRatio(mainReferences.cardAspectRatio), frame: self.view.frame.centerScaledBy(factor: 0.95))
    
    
    private var newCardViews = [CardView]()
    
    private var cardViewsToCards = [Card:CardView]()
    
    private var cardViews = [CardView](){
        didSet{
            grid.cellCount = game.cardsOnTable.count
            for cardView in cardViews{
                print(cardView.index)
                place(card: cardView)
            }
            newCardViews = []
        }
    }
    
    
    func place(card :CardView){
            let index = card.index
        if let initialFrame = grid[index]{
            let frame = initialFrame.insetBy(dx: initialFrame.width * 1/20, dy: initialFrame.height * 1/20)
        let finalFrame =  frame.centerScaledBy(factor: card.isSelected ? selectedCardToOriginal.frame : 1) 
            if newCardViews.contains(card){
                card.frame = CGRect(origin: CGPoint(x:self.view.bounds.midX,y: 1.5 * self.view.bounds.maxY), size: CGSize.zero)
                UIView.animateKeyframes(withDuration: 0.5  , delay: 0.1 + Double(newCardViews.firstIndex(of: card)!)/10 , animations: {  card.frame = finalFrame})
            }else{
            UIView.animate(withDuration: 0.5, animations: {card.frame = finalFrame})
        }
        }
    }
    
    
    private var selectedCards = [CardView](){
        didSet{
            if selectedCards.count == 3{
                for card in selectedCards{
                    let indexOfSelectedCard = card.index
                    cardViewsToCards[game.cardsOnTable[card.index]] = nil
                    game.removeCardsFromGameByCardIndexes([indexOfSelectedCard])
                    cardViews.remove(at: indexOfSelectedCard)
                    card.removeFromSuperview()
                }
                selectedCards = []
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
    
    private func isCardViewRepresentingThisCard(cardView: CardView, card : Card) -> Bool{
        return  (cardView.color == colors[card.color]!) && (cardView.fill == fill[card.fill]!)&&(cardView.number == card.number)&&(cardView.shape == shapes[card.shape]!)

    }
    
    
    
//    private func updateViewFromModel(){
//        for cardIndex in game.cardsOnTable.indices{
//            grid.cellCount = game.cardsOnTable.count
//            if cardIndex + 1 <= cardViews.count{
//            }else{
//                let newCard = CardView()
//                let cardSelectGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectCard(recognizer:)))
//                newCard.addGestureRecognizer(cardSelectGestureRecognizer)
//                cardSelectGestureRecognizer.delegate = self
//                newCard.isOpaque = false
//
//                newCard.index = cardIndex
//                makeCardAndRepresentingViewEqual(cardView: newCard, card: game.cardsOnTable[cardIndex])
//                self.view.addSubview(newCard)
//                newCardViews.append(newCard)
//            }
//        }
//        cardViews += newCardViews
//    }
    
//    private func updateViewFromModel(){
//        for cardIndex in game.cardsOnTable.indices{
//            if cardIndex > cardViews.count{
//                let newCard = CardView()
//                let cardSelectGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectCard(recognizer:)))
//                newCard.addGestureRecognizer(cardSelectGestureRecognizer)
//                cardSelectGestureRecognizer.delegate = self
//                newCard.isOpaque = false
//
//                newCard.index = cardIndex
//                makeCardAndRepresentingViewEqual(cardView: newCard, card: game.cardsOnTable[cardIndex])
//                self.view.addSubview(newCard)
//                newCardViews.append(newCard)
//            }else if !isCardViewRepresentingThisCard(cardView: cardViews[cardIndex], card: game.cardsOnTable[cardIndex]){
//                let newCard = CardView()
//                let cardSelectGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectCard(recognizer:)))
//                newCard.addGestureRecognizer(cardSelectGestureRecognizer)
//                cardSelectGestureRecognizer.delegate = self
//                newCard.isOpaque = false
//
//                newCard.index = cardIndex
//                makeCardAndRepresentingViewEqual(cardView: newCard, card: game.cardsOnTable[cardIndex])
//                self.view.addSubview(newCard)
//                newCardViews.append(newCard)
//            }
//        }
//        cardViews += newCardViews
//    }
    
    
    private func updateViewFromModel(){
        
        grid.cellCount = game.cardsOnTable.count
        for cardIndex in game.cardsOnTable.indices{
            let card = game.cardsOnTable[cardIndex]
            if let cardView = cardViewsToCards[card]{
                cardView.index = cardIndex
            }else{
                let newCard = CardView()
                let cardSelectGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectCard(recognizer:)))
                newCard.addGestureRecognizer(cardSelectGestureRecognizer)
                cardSelectGestureRecognizer.delegate = self
                newCard.isOpaque = false
                cardViewsToCards[card] = newCard
                
                newCard.index = cardIndex
                makeCardAndRepresentingViewEqual(cardView: newCard, card: game.cardsOnTable[cardIndex])
                self.view.addSubview(newCard)
                place(card: newCard)
               // newCardViews.append(newCard)
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
                if !sender.isSelected{
                    selectedCards.append(sender)
                }else{
                    if let indexOfSelectedCardView = selectedCards.firstIndex(of: sender){
                        selectedCards.remove(at: indexOfSelectedCardView)
                    }
                }
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
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: timeIntervals.cardSelection,
                                                       delay: 0,
                                                       options: [UIView.AnimationOptions.allowUserInteraction,.curveEaseInOut,.beginFromCurrentState] ,
                                                       animations: {cardView.centerScaleBy(factor: cardView.isSelected ? 1 / selectedCardToOriginal.frame : selectedCardToOriginal.frame)
                                                        cardView.alpha = cardView.isSelected ? 1 : selectedCardToOriginal.alpha
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
    
    func centerScaledBy(factor: CGFloat) -> CGRect{
        let newOrigin = CGPoint(x: origin.x + self.width*(1-factor)/2, y: origin.y + self.height*(1-factor)/2)
        return CGRect(origin: newOrigin, size: self.size.scaledBy(factor: factor))
        
    }
}

extension CGSize{
    func scaledBy(factor: CGFloat) -> CGSize {
        return CGSize(width: self.width * factor, height: self.height * factor)
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

//extension Array{
//    func removeElement(for element: Element) -> Element?{
//        let firstIndex = self.firstIndex
//    }
//}


//MARK: AnimationsConsts
struct timeIntervals{
    static let cardSelection:Double =  0.1
}
//SelecionAnimationParameters
struct selectedCardToOriginal{
    static let frame:CGFloat = 0.8
    static let alpha: CGFloat = 0.8
}

struct mainReferences{
    static let cardAspectRatio: CGFloat = 56/87
}

