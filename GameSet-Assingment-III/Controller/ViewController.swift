//
//  ViewController.swift
//  GameSet_Assingment3
//
//  Created by Boris V on 02.03.2018.
//  Copyright © 2018 GRIAL. All rights reserved.
//
import UIKit

class ViewController: UIViewController {
    
    private var gameSet = GameSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
    
    @IBOutlet private weak var boardView: BoardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(more3cards))
            swipe.direction = .down
            boardView.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(reshuffle))
            boardView.addGestureRecognizer(rotate)
            
            let swipeTwoPlayers = UISwipeGestureRecognizer(target: self, action: #selector(twoPlayers))
            swipeTwoPlayers.direction = .up
            boardView.addGestureRecognizer(swipeTwoPlayers)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(leftPlayer))
            swipeLeft.direction = .left
            boardView.addGestureRecognizer(swipeLeft)
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(rightPlayer))
            swipeRight.direction = .right
            boardView.addGestureRecognizer(swipeRight)
            
        }
    }
    
    @IBOutlet weak var tooglePlayers: UILabel!
    
    private func updateViewFromModel() {
        currentDeck.setTitle("\(gameSet.cards.count)" + "➙3", for: .normal)
        if boardView.cardViews.count > gameSet.visibleCards.count {
            let cardViews = boardView.cardViews [..<gameSet.visibleCards.count]
            boardView.cardViews = Array(cardViews)
        }
        for index in gameSet.visibleCards.indices {
            let card = gameSet.visibleCards[index]
            if index >= boardView.cardViews.count { // new cards
                let cardView = SetCardView()
                updateCardView(cardView, card)
                let tap = UITapGestureRecognizer(target: self, action: #selector(chooseCard))
                tap.numberOfTapsRequired = 1
                tap.numberOfTapsRequired = 1
                cardView.addGestureRecognizer(tap)
                boardView.cardViews.append(cardView)
            } else { // Replace old cards
                let cardView = boardView.cardViews[index]
                updateCardView(cardView, card)
            }
        }
        if gameSet.hint == false {
            allSetsOrTimer.text = "(\(gameSet.hintSets.count))"
        }
        if gameSet.hint == true {
            iphoneScoreOrHints.text = "\(gameSet.numberOfHints)"
            
        }
        score.text = gameSet.scoreOfPlayer
        if gameSet.cards.isEmpty {
            currentDeck.isEnabled = false // блокировка кнопки more3cards
            if gameSet.hintSets.count == 0 || gameSet.visibleCards.count < 6 {
                tooglePlayers.text = "🏁"
            }
        }
    }
    
    private let symbols = ["diamond", "oval", "squiggle"]
    private let colors = [ #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1), #colorLiteral(red: 0.07843137255, green: 0.6078431373, blue: 0.2666666667, alpha: 1) ]
    private let fills = ["unfilled", "solid", "striped"]
    
    private func updateCardView(_ cardView: SetCardView, _ card: CardSet) {
        cardView.number = card.number.rawValue
        cardView.symbol = symbols[card.symbol.rawValue]
        cardView.color = colors[card.color.rawValue]
        cardView.fill = fills[card.fill.rawValue]
        cardView.layerState()
        guard gameSet.selectedCards.contains(card) else {
            return  cardView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor }
        if gameSet.selectedCards.count == gameSet.flop {
            if gameSet.match {
                cardView.layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1).cgColor
            } else {
                cardView.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
            }
        } else {
            cardView.layer.borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1).cgColor
        }
    }
    
    @objc private func reshuffle(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            gameSet.shuffle()
            updateViewFromModel()
        }
    }
    
    @objc private func chooseCard(_ sender: UITapGestureRecognizer) {
        if let cardView = sender.view as? SetCardView,
            let cardIndex = boardView.cardViews.index(of: cardView),
            sender.state == .ended {
            gameSet.chooseCard(at: cardIndex)
            updateViewFromModel()
        }
    }
    
    @IBOutlet private weak var iphoneScoreOrHints: UILabel!
    
    @objc private func twoPlayers(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            gameSet = GameSet()
            allSetsOrTimer.text = "🤺"
            iphoneOrDango.setTitle("🤺", for: .normal)
            tooglePlayers.text = "⇨"
            currentDeck.isEnabled = false
            iphoneOrDango.isEnabled = false
            gameSet.playerVsPlayer()
            updateViewFromModel()
        }
    }
    
    @objc private func leftPlayer(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended, gameSet.hint == true {
            gameSet.doublesLeft()
            tooglePlayers.text = "⇦"
            updateViewFromModel()
        }
    }
    
    @objc private func rightPlayer(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended, gameSet.hint == true {
            gameSet.doublesRight()
            tooglePlayers.text = "⇨"
            updateViewFromModel()
        }
    }
    
    @IBOutlet private weak var iphoneOrDango: UIButton!
    @IBAction private func iphoneOrHanami() {
        gameSet.hintSet()
        updateViewFromModel()
        
        iphoneScoreOrHints.text = "\(gameSet.numberOfHints)"
    }
    
    @IBOutlet private weak var allSetsOrTimer: UILabel!
    
    @IBOutlet private weak var currentDeck: UIButton!
    @IBAction private func more3cards() {
        guard !gameSet.cards.isEmpty && gameSet.hint != true else { return}
        if !gameSet.match { //  не выбран сет
            gameSet.addCards(few: gameSet.flop)
        } else {
            gameSet.addFlopNowSet()
        }
        tooglePlayers.text = ""
        updateViewFromModel()
    }
    
    @IBOutlet private weak var score: UILabel!
    @IBAction private func newGame() {
        gameSet = GameSet()
        iphoneOrDango.setTitle("🍡", for: .normal)
        iphoneOrDango.isEnabled = true
        iphoneScoreOrHints.text = ""
        allSetsOrTimer.text = ""
        tooglePlayers.text = "🤺"
        currentDeck.isEnabled = true // снятие блокировки кнопки more3cards
        updateViewFromModel()
    }
}
