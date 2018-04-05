//
//  BoardView.swift
//  GameSet_Assingment3
//
//  Created by Борис Винник on 31.03.2018.
//  Copyright © 2018 GRIAL. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    
    var cardViews = [SetCardView]() {
        willSet { removeSubviews() }
        didSet { addSubviews(); setNeedsLayout() }
    }
    
    private func removeSubviews() {
        for card in cardViews {
            card.removeFromSuperview()
        }
    }
    
    private func addSubviews() {
        for card in cardViews {
            addSubview(card)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSetCards()
    }
    
    private func layoutSetCards() {
        var grid = Grid(layout: .aspectRatio(Constant.cellAspectRatio), frame: bounds)
        grid.cellCount = cardViews.count
        for index in 0..<grid.cellCount {
            if let frame = grid[index] {
                let clearance = Constant.cellClearanceToBoundsWidth * frame.width
                let cardFrame = CGRect(x: frame.origin.x, y: frame.origin.y,
                                       width: frame.width - clearance,
                                       height: frame.height - clearance)
                let setCardView = cardViews[index]
                setCardView.frame = cardFrame
            }
        }
    }
}

extension BoardView {
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.62
        static let cellClearanceToBoundsWidth: CGFloat = 0.05 // зазор между картами
    }
}

