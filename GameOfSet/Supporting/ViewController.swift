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
    
    //MARK: Properties
    
    private var shapes = [Shape.triangle: CardShape.triangle,Shape.circle: CardShape.oval,Shape.square: CardShape.wave]
    private var colors = [Color.first: #colorLiteral(red: 0, green: 0.726098001, blue: 0, alpha: 1), .second: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), .third: #colorLiteral(red: 0.4170517325, green: 0, blue: 0.5548704267, alpha: 1)]
    private var fill = [Fill.none: CardFill.none ,Fill.striped: CardFill.stripped, Fill.full: CardFill.full]
    
    private var game = SetGame(){
        didSet{
            updateViewFromModel()
        }
    }
    
    private var setOnTable: [CardView]?
    
    private weak var timer: Timer?
    
    lazy private var grid = Grid(layout: Grid.Layout.aspectRatio(mainReferences.cardAspectRatio), frame: self.cardDrawingView.frame )
    
    
    @IBOutlet weak var cardDrawingView: UIView!
    
    
    private var newCardViews = [CardView]()
    
    private var cardViewsToCards = [Card:CardView]()
    private var cardViews = [CardView]()
    
    
    func place(card :CardView){
        let index = card.index
            if let initialFrame = grid[index]{
            let frame = initialFrame.insetBy(dx: initialFrame.width * 1/20, dy: initialFrame.height * 1/20)
            let finalFrame = frame.centerScaledBy(factor: card.isSelected ? selectedCardToOriginal.frame : 1) 
            UIView.animate(withDuration: 0.5, animations: {card.frame = finalFrame})
        }
    }
    
    
    func placeNewCard(_ card: CardView, with interval: TimeInterval){
        let index = card.index
        if let initialFrame = grid[index]{
            let frame = initialFrame.insetBy(dx: initialFrame.width * 1/20, dy: initialFrame.height * 1/20)
            card.frame = CGRect(origin: CGPoint(x:self.view.bounds.midX,y: 1.5 * self.view.bounds.maxY), size: CGSize.zero)
            UIView.animateKeyframes(withDuration: 0.5  , delay: interval  , animations: {  card.frame = frame})
        }
    }
    
    
    private var selectedCards = [CardView](){
        didSet{
            if selectedCards.count == 3{
                self.view.isUserInteractionEnabled = false
                timer = Timer.scheduledTimer(withTimeInterval: timeIntervals.cardSelection * 2, repeats: false){_ in
                    self.examineSelection()
                }
            }
        }
    }
    
    //MARK: Functions
    
    
    
    private func examineSelection(){
        var selectedCardIndexes = selectedCards.map{$0.index}
        selectedCardIndexes.sort()
        if game.checkSelectedCardsForSet(by:selectedCardIndexes){
            for cardView in selectedCards{
                cardViews.remove(at: cardViews.firstIndex(of: cardView)!)
                cardViewsToCards[game.cardsOnTable[cardView.index]] = nil
                animateCardViewDissapearance(cardView)
                game.removeAndDrawCardsOnTable(for: selectedCardIndexes)
        }
            self.setOnTable = nil
        }else{
            for cardView in selectedCards{
                animateCardSelection(for: cardView)
                cardView.isSelected = false
            }
        }
        self.view.isUserInteractionEnabled = true
        selectedCards = []
        updateViewFromModel()
    }
    
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
    

    
    
    private func updateViewFromModel(){
        grid.cellCount = game.cardsOnTable.count
        var numberOfNewCards = 0
        for cardIndex in game.cardsOnTable.indices{
            let card = game.cardsOnTable[cardIndex]
            if let cardView = cardViewsToCards[card]{
                cardView.index = cardIndex
                place(card: cardView)
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
                placeNewCard(newCard,with: 0.1 * Double(numberOfNewCards))
                cardViews.append(newCard)
                numberOfNewCards += 1
            }
        }
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
                    sender.isSelected = !sender.isSelected
                    selectedCards.append(sender)
                }else{
                    sender.isSelected = !sender.isSelected
                    if let indexOfSelectedCardView = selectedCards.firstIndex(of: sender){
                        selectedCards.remove(at: indexOfSelectedCardView)
                    }
                }
            }
        default: break
        }
    }
    
    @objc func deal3MoreCards(recognizer: UISwipeGestureRecognizer){
        switch recognizer.state{
        case .ended:
            setOnTable = game.IsThereASetOnTable()?.map{cardViewsToCards[$0]!}
            if setOnTable == nil{
            game.deal3MoreCards()
            updateViewFromModel()
            }else{
                animateThereIsASetOnTable(for: cardViews)
            }
//            game.deal3MoreCards()
//            updateViewFromModel()
        default: break
        }
    }
    
    @objc func showSetOnTable(recongizer: UISwipeGestureRecognizer){
        switch recongizer.state{
        case .ended:
            if let currentSet = setOnTable{
                self.animateSetAppearence(for: currentSet)
            }else{
                self.setOnTable = game.IsThereASetOnTable()?.map{cardViewsToCards[$0]!}
                if let currentSet = setOnTable{
                    animateSetAppearence(for: currentSet)
                }
            }
        default: break
        }
    }
    
    @objc func shuffleTheCards(recognizer: UIRotationGestureRecognizer){
        switch recognizer.state{
        case .ended:
            for cardView in cardViews{
                animateCardViewReshuffling(cardView)
            }
            cardViews = []
            cardViewsToCards = [:]
            game.reshuffleCards()
            updateViewFromModel()
        default: break
        }
    }
    
    //MARK: Animations
    
    func animateCardSelection(for cardView: CardView){
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: timeIntervals.cardSelection,
                                                       delay: 0,
                                                       options: [UIView.AnimationOptions.allowUserInteraction,.curveEaseInOut] ,
                                                       animations: {cardView.centerScaleBy(factor: cardView.isSelected ? 1 / selectedCardToOriginal.frame : selectedCardToOriginal.frame)
                                                        cardView.alpha = cardView.isSelected ? 1 : selectedCardToOriginal.alpha
        })
    }
    
    func animateThereIsASetOnTable(for cards: [CardView]){
        var cardViews = cards
        cardViews.randomize()
        for cardIndex in cards.indices{
            let card = cardViews[cardIndex]
            UIView.animate(withDuration: 0.1, delay: Double(cardIndex) * 0.03, animations: {card.frame = card.frame.centerScaledBy(factor: 0.8)}, completion:{ state in
                UIView.animate(withDuration: 0.1, animations:{ card.frame = card.frame.centerScaledBy(factor: 1/0.8)})
            })
        }
    }
    
    func animateSetAppearence(for cards: [CardView]){
        for cardIndex in cards.indices{
            let cardView = cards[cardIndex]
            UIView.animateKeyframes(withDuration: 0.3, delay: 0.0 , options: .beginFromCurrentState, animations: {cardView.frame = cardView.frame.centerScaledBy(factor: 1.2)}, completion:{ state in
                UIView.animate(withDuration: 0.3){cardView.frame = cardView.frame.centerScaledBy(factor: 1/1.2)}
            })
        }
    }
    
    func animateCardViewDissapearance(_ cardView: CardView){
        UIView.animate(withDuration: 0.4, animations: {cardView.frame = cardView.frame.centerScaledBy(factor: 0.0001)}, completion: {state in cardView.removeFromSuperview()})
        
    }
    
    
    func animateCardViewReshuffling(_ cardView: CardView){
        let randomDouble = CGFloat.random(in: 0...CGFloat.pi)
        UIView.animate(withDuration: 0.4, animations: {cardView.frame = CGRect(origin: self.view.center + (2 * self.view.bounds.width * cos(randomDouble), -2 * self.view.bounds.height * sin(randomDouble)), size: CGSize.zero)}, completion: {state in cardView.removeFromSuperview()})
    }
    
    //MARK: Utility Functions
    
    override func viewDidLoad() {
        updateViewFromModel()
        selectingFeedbackGenerator.prepare()
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.deal3MoreCards(recognizer:)))
        downSwipeGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(downSwipeGestureRecognizer)
        downSwipeGestureRecognizer.delegate = self
        
        
        let upSwipeGestureRecongizer = UISwipeGestureRecognizer(target: self, action: #selector(showSetOnTable(recongizer:)))
        upSwipeGestureRecongizer.direction = .up
        self.view.addGestureRecognizer(upSwipeGestureRecongizer)
        upSwipeGestureRecongizer.delegate = self
        
        let rotationGestureRecoginzer = UIRotationGestureRecognizer(target: self, action: #selector(shuffleTheCards(recognizer:)))
        self.view.addGestureRecognizer(rotationGestureRecoginzer)
        rotationGestureRecoginzer.delegate = self
    }
    
    override func viewDidLayoutSubviews(){
        grid.frame = self.cardDrawingView.frame
        updateViewFromModel()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
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

