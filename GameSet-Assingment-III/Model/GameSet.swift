//
//  GameSet1.swift
//  GameSet_Assingment1
//
//  Created by Boris V on 02.12.2017.
//  Copyright © 2017 GRIAL. All rights reserved.
//
import Foundation

struct GameSet {
    
    private(set) var cards = [CardSet]()
    //========Const=======
    private let order = 12
    let flop = 3
    private let award = 10
    //====================
    init() {
        startDeck()
    }
    
    private mutating func startDeck() {
        for symbol in CardSet.Triplet.all {
            for number in CardSet.Triplet.all {
                for color in CardSet.Triplet.all {
                    for fill in CardSet.Triplet.all {
                        cards.append(CardSet(symbol: symbol, number: number, color: color, fill: fill))
                    }
                }
            }
        }
        addCards(few: order)
    }
    
    private(set) var visibleCards = [CardSet]()
    private(set) var selectedCards = [CardSet]()
    
    private var penalty: Int {
        return abs(visibleCards.count - order) * 3
    }
    
    var match: Bool {
        guard selectedCards.count == flop else { return false}
        return CardSet.checkSet(cards: selectedCards)
    }
    
    private var max = 0
    private(set) var numberOfHints = 0
    private(set) var hint: Bool? //флаг использования подсказки/парной игры
    
    mutating func chooseCard(at index: Int) {
        let card = visibleCards[index]
        if !selectedCards.contains(card) {
            if selectedCards.count == flop {
                if match {
                    addFlopNowSet()
                } else {
                    if hintSets.count != 0 {
                        if toggle == true {
                            numberOfHints -= penalty + 3
                        } else {
                            max -= penalty + 3 // -3,-12,-21,-30,-39
                        }
                    }
                }
                selectedCards.removeAll()
            }
            selectedCards += [card]
            if hint == true { //авто-удаление сета при парной игре
                if match {
                    addFlopNowSet()
                }
            }
        } else {
            if selectedCards.count != flop {
                selectedCards.remove(elements: [card])
                if hintSets.count != 0 {
                    if toggle == true {
                        numberOfHints -= 1
                    } else {
                        max -= 1
                    }
                }
            }
        }
    }
    
    mutating func addFlopNowSet() {
        if toggle == true {
            numberOfHints += award
        } else {
            max += award
        }
        visibleCards.remove(elements: selectedCards)
        selectedCards.removeAll()
        if !cards.isEmpty, visibleCards.count < order {
            addCards(few: flop)
        }
        // Если при парной игре нет сета, то добавить карт
        if hintSets.count == 0, hint == true {
            while hintSets.count == 0 && !cards.isEmpty {
                addCards(few: flop)
            }
        }
        
    }
    
    var scoreOfPlayer: String {
        return String(max)
    }
    
    mutating func addCards( few: Int) {
        let hintsCount = hintSets.count
        let count = selectedCards.count + penalty
        for _ in 1...few {
            visibleCards.append(draw())
        }
        if hintsCount != 0 {
            max -= penalty  // -9,-18,-27,-36
            if selectedCards.count == flop, !match {
                max -= count
            }
        }
        selectedCards.removeAll()
        print(hintSets)
    }
    
    private mutating func draw() -> CardSet {
        return cards.remove(at: cards.count.arc4random)
    }
    
    var hintSets: [[Int]] {
        var hints = [[Int]]()
        for i in 0..<visibleCards.count {
            for j in (i+1)..<visibleCards.count {
                for k in (j+1)..<visibleCards.count {
                    let cards = [visibleCards[i], visibleCards[j], visibleCards[k]]
                    if CardSet.checkSet(cards: cards) {
                        hints.append([i,j,k])
                    }
                }
            }
        }
        return hints
    }
    
    mutating func hintSet() { // подсказка случайного сета
        hint = false // флаг подсказки при игре "соло"
        guard hintSets.count != 0 else { return}
        guard !match  else { return }
        numberOfHints += 1
        if selectedCards.count == flop, !match {
            max -= penalty + award + flop
        } else {
            max -= selectedCards.count + award
        }
        selectedCards.removeAll()
        if hintSets.count != 0 {
            let randomIndex = hintSets.count.arc4random
            for index in 0..<flop {
                selectedCards.append(visibleCards[hintSets[randomIndex][index]])
            }
        }
    }
    
    mutating func shuffle() {
        for index in visibleCards.indices {
            visibleCards.swapAt(index.arc4random, index)
        }
    }
    
    mutating func playerVsPlayer() {
        hint = true
        if hintSets.count == 0 {
            // Если не обнаружен сет, то добавить карт
            while hintSets.count == 0 {
                addCards(few: flop)
            }
        }
    }
    
    private var toggle = false // флаг активного счётчика
    mutating func doublesLeft() {
        if !toggle {
            selectedCards.removeAll()
            toggle = true
        }
    }
    
    mutating func doublesRight() {
        if toggle {
            selectedCards.removeAll()
            toggle = false
        }
    }
}

extension Int {
    var arc4random: Int {
        guard self > 0 else { return 0}
        return Int(arc4random_uniform(UInt32(self)))
    }
}

extension Array where Element : Equatable {
    mutating func remove(elements: [Element]){
        self = self.filter { !elements.contains($0) }
    }
}


