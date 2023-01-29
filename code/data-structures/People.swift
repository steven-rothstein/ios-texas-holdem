//
//  People.swift
//  TexasHoldem
//
//  Created by Steven Rothstein on 9/30/18.
//  Copyright © 2018 Steven Rothstein. All rights reserved.
//

import Foundation

struct Dealer {
    var deck = Deck()
}

class Player {
    let isComputer: Bool
    let name: String
    private var hand: Set<Card>
    private var currentBet: Int
    
    init(isComputer: Bool, name: String) {
        self.isComputer = isComputer
        self.name = name
        self.hand = Set<Card>()
        self.currentBet = 0
    }
    
    func copyPlayer() -> Player {
        let copy = Player(isComputer: self.isComputer, name: self.name)
        for card in self.hand {
            copy.hand.insert(card)
        }
        return copy
    }
    
    func getHand() -> Set<Card> {
        return hand
    }
    
    func addCardToHand(card: Card) {
        hand.insert(card)
    }
    
    func addCardsToHand(cards: [Card]) {
        for card in cards {
            addCardToHand(card: card)
        }
    }
    
    func clearHand() {
        hand = Set<Card>()
    }
    
    func getCurrentBet() -> Int {
        return self.currentBet
    }
    
    func raiseCurrentBet(raiseAmount: Int) {
        currentBet += raiseAmount
    }
    
    func clearCurrentBet() {
        currentBet = 0
    }
}
