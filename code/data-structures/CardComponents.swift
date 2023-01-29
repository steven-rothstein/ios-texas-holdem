//
//  CardComponents.swift
//  TexasHoldem
//
//  Created by Steven Rothstein on 9/30/18.
//  Copyright © 2018 Steven Rothstein. All rights reserved.
//

import Foundation

protocol CardComponent {}

enum Suit: String, CaseIterable, CardComponent {
    case hearts
    case diamonds
    case spades
    case clubs
}

enum CardType: Int, CaseIterable, CardComponent {
    case two = 2, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace
    
    func getStringValue() -> String {
        switch (self) {
        case .two:
            return "two"
        case .three:
            return "three"
        case .four:
            return "four"
        case .five:
            return "five"
        case .six:
            return "six"
        case .seven:
            return "seven"
        case .eight:
            return "eight"
        case .nine:
            return "nine"
        case .ten:
            return "ten"
        case .jack:
            return "jack"
        case .queen:
            return "queen"
        case .king:
            return "king"
        case .ace:
            return "ace"
        }
    }
}

enum CardActions: Int, CaseIterable {
    case check = 0, call, raise, fold, bet
    
    func getStringValue() -> String {
        switch (self) {
        case .check:
            return "Check"
        case .call:
            return "Call"
        case .raise:
            return "Raise"
        case .fold:
            return "Fold"
        case .bet:
            return "Bet"
        }
    }
}

struct Card: Hashable {
    let suit: Suit
    let cardType: CardType
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return (lhs.suit == rhs.suit) && (lhs.cardType == rhs.cardType)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(suit)
        hasher.combine(cardType)
    }
}

struct Deck {
    private var cards: [Card]
    
    init() {
        cards = [Card]()
        for cardType in CardType.allCases {
            for suit in Suit.allCases {
                cards.append(Card(suit: suit, cardType: cardType))
            }
        }
        shuffle()
    }
    
    mutating func shuffle() {
        for index in stride(from: cards.count-1, through: 1, by: -1) {
            let j = Int.random(in: 0...index)
            let tmp = cards[index]
            cards[index] = cards[j]
            cards[j] = tmp
        }
    }
    
    mutating func takeFromTop(numCards: Int) -> [Card] {
        var popped = [Card]()
        let validNumCards = ((1 <= numCards) && (numCards <= cards.count))
        
        if (validNumCards) {
            for _ in 0..<numCards {
                popped.append(cards.popLast()!)
            }
        }
        return popped
    }
    
    func printDeck() {
        for card in cards {
            print("\(card.cardType) \t \(card.suit)")
        }
        print(cards.count)
    }
}
