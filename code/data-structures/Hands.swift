//
//  Hands.swift
//  TexasHoldem
//
//  Created by Steven Rothstein on 10/2/18.
//  Copyright © 2018 Steven Rothstein. All rights reserved.
//

import Foundation

protocol Hand {
    var cards: Set<Card> { get }
    var name: String { get }
    static var rank: HandUtility.HandRank { get }
    func getRank() -> HandUtility.HandRank
}

struct HandUtility {
    private static let determineWinnerFunctionsArr = [(HighCard.rank, SameHandWinnerFunctions.HIGHCARD(HighCard.determineWinner)),
                                                      (OnePair.rank, SameHandWinnerFunctions.ONEPAIR(OnePair.determineWinner)),
                                                      (TwoPair.rank, SameHandWinnerFunctions.TWOPAIR(TwoPair.determineWinner)),
                                                      (ThreeOfAKind.rank, SameHandWinnerFunctions.THREEOFAKIND(ThreeOfAKind.determineWinner)),
                                                      (Straight.rank, SameHandWinnerFunctions.STRAIGHT(Straight.determineWinner)),
                                                      (Flush.rank, SameHandWinnerFunctions.FLUSH(Flush.determineWinner)),
                                                      (FullHouse.rank, SameHandWinnerFunctions.FULLHOUSE(FullHouse.determineWinner)),
                                                      (FourOfAKind.rank, SameHandWinnerFunctions.FOUROFAKIND(FourOfAKind.determineWinner)),
                                                      (StraightFlush.rank, SameHandWinnerFunctions.STRAIGHTFLUSH(StraightFlush.determineWinner))]
    
    static let factoryFunctionsArr = [FactoryFunctions.STRAIGHTFLUSH(StraightFlush.StraightFlushFactory),
                                      FactoryFunctions.FOUROFAKIND(FourOfAKind.FourOfAKindFactory),
                                      FactoryFunctions.FULLHOUSE(FullHouse.FullHouseFactory),
                                      FactoryFunctions.FLUSH(Flush.FlushFactory),
                                      FactoryFunctions.STRAIGHT(Straight.StraightFactory),
                                      FactoryFunctions.THREEOFAKIND(ThreeOfAKind.ThreeOfAKindFactory),
                                      FactoryFunctions.TWOPAIR(TwoPair.TwoPairFactory),
                                      FactoryFunctions.ONEPAIR(OnePair.OnePairFactory),
                                      FactoryFunctions.HIGHCARD(HighCard.HighCardFactory)]
    
    enum FactoryFunctions {
        case HIGHCARD((Set<Card>) -> HighCard)
        case ONEPAIR((Set<Card>) -> OnePair?)
        case TWOPAIR((Set<Card>) -> TwoPair?)
        case THREEOFAKIND((Set<Card>) -> ThreeOfAKind?)
        case STRAIGHT((Set<Card>) -> Straight?)
        case FLUSH((Set<Card>) -> Flush?)
        case FULLHOUSE((Set<Card>) -> FullHouse?)
        case FOUROFAKIND((Set<Card>) -> FourOfAKind?)
        case STRAIGHTFLUSH((Set<Card>) -> StraightFlush?)
    }
    
    enum SameHandWinnerFunctions {
        case HIGHCARD((HighCard, HighCard) -> HighCard?)
        case ONEPAIR((OnePair, OnePair) -> OnePair?)
        case TWOPAIR((TwoPair, TwoPair) -> TwoPair?)
        case THREEOFAKIND((ThreeOfAKind, ThreeOfAKind) -> ThreeOfAKind?)
        case STRAIGHT((Straight, Straight) -> Straight?)
        case FLUSH((Flush, Flush) -> Flush?)
        case FULLHOUSE((FullHouse, FullHouse) -> FullHouse?)
        case FOUROFAKIND((FourOfAKind, FourOfAKind) -> FourOfAKind?)
        case STRAIGHTFLUSH((StraightFlush, StraightFlush) -> StraightFlush?)
    }
    
    enum HandRank: Int {
        case ONE = 1, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE
    }
    
    static func createSuitMapCount(cards: Set<Card>) -> [Suit : Int] {
        let retVal: [Suit : Int] = createMapCount(cards: cards, checkSuit: true)
        return retVal
    }
    
    static func createCardTypeMapCount(cards: Set<Card>) -> [CardType : Int] {
        let retVal: [CardType : Int] = createMapCount(cards: cards, checkSuit: false)
        return retVal
    }
    
    static func checkSuitCompliance(cards: Set<Card>, thresholds: Int...) -> (compliant: Bool, returnKeyValues: [(Suit, Int)]?, returnMap: [Suit : Int]?) {
        if (thresholds.count == 0) {
            return (false, nil, nil)
        }
        let myMap = createSuitMapCount(cards: cards)
        let (acceptable, keyValues) = mapCountsAcceptable(map: myMap, checkEqual: false, thresholds: thresholds)
        return (acceptable, keyValues, myMap)
    }
    
    static func checkCardTypeCompliance(cards: Set<Card>, thresholds: Int...) -> (compliant: Bool, returnKeyValues: [(CardType, Int)]?, returnMap: [CardType : Int]?) {
        if (thresholds.count == 0) {
            return (false, nil, nil)
        }
        let myMap = createCardTypeMapCount(cards: cards)
        let (acceptable, keyValues) = mapCountsAcceptable(map: myMap, thresholds: thresholds)
        return (acceptable, keyValues, myMap)
    }
    
    private static func createMapCount<T: CardComponent>(cards: Set<Card>, checkSuit: Bool) -> [T : Int] {
        var map = [T : Int]()
        
        for card in cards {
            let suitOrCardType: T
            if (checkSuit) {
                suitOrCardType = card.suit as! T
            } else {
                suitOrCardType = card.cardType as! T
            }
            
            if (map.keys.contains(suitOrCardType)) {
                map[suitOrCardType] = map[suitOrCardType]! + 1
            } else {
                map[suitOrCardType] = 1
            }
        }
        
        return map
    }
    
    private static func mapCountsAcceptable<T: CardComponent>(map: [T : Int], checkEqual: Bool = true, thresholds: [Int]) -> (acceptable: Bool, keyValues: [(T, Int)]?) {
        var keysToSkip = Set<T>()
        var keyValuesReturn = [(T, Int)]()
        
        var funcToUse: (Int, Int) -> Bool = (==)
        if (!checkEqual) {
            funcToUse = (>=)
        }
        
        for threshold in thresholds {
            var currentFound = false
            for (key, count) in map {
                if (funcToUse(count, threshold) && !(keysToSkip.contains(key))) {
                    keysToSkip.insert(key)
                    keyValuesReturn.append((key, count))
                    currentFound = true
                }
            }
            
            if (!currentFound) {
                return (false, nil)
            }
        }
        return (true, keyValuesReturn)
    }
    
    private static func cardSorterAscHelper(card1: Card, card2: Card) -> Bool {
        return cardTypeSorterAscHelper(card1: card1.cardType, card2: card2.cardType)
    }
    
    private static func cardTypeSorterAscHelper(card1: CardType, card2: CardType) -> Bool {
        return card1.rawValue < card2.rawValue
    }
    
    static func cardSorterAsc(cards: Set<Card>) -> [Card] {
        var retVal = Array(cards)
        retVal.sort(by: cardSorterAscHelper)
        return retVal
    }
    
    static func subtractHands(leftHand: Set<Card>, rightHand: Set<Card>) -> (leftHandOnly: Set<Card>, rightHandOnly: Set<Card>) {
        return (leftHand.subtracting(rightHand), rightHand.subtracting(leftHand))
    }
    
    static func getMax(hand: Set<Card>) -> Card? {
        return hand.max(by: HandUtility.cardSorterAscHelper)
    }
    
    static func getMax(hand: [CardType]) -> CardType? {
        return hand.max(by: HandUtility.cardTypeSorterAscHelper)
    }
    
    private static func remove(cardType: CardType, fromArr: [CardType]) -> [CardType] {
        var retVal = fromArr
        var x = 0
        while (x < retVal.count) {
            if (retVal[x] == cardType) {
                retVal.remove(at: x)
            } else {
                x = x + 1
            }
        }
        return retVal
    }
    
    static func remove(cardType: CardType, fromSet: Set<Card>) -> Set<Card> {
        var newSet = fromSet
        for card in newSet {
            if (card.cardType == cardType) {
                newSet.remove(card)
            }
        }
        return newSet
    }
    
    static func remove(cardTypes: [CardType], fromSet: Set<Card>) -> Set<Card> {
        var retVal = fromSet
        for cardType in cardTypes {
            retVal = HandUtility.remove(cardType: cardType, fromSet: retVal)
        }
        return retVal
    }
    
    static func determineMaxWinner(leftCTArr: [CardType], rightCTArr: [CardType]) -> [CardType]? {
        var leftCTArrCopy = leftCTArr
        var rightCTArrCopy = rightCTArr
        
        while (true) {
            let leftMax = HandUtility.getMax(hand: leftCTArrCopy)
            let rightMax = HandUtility.getMax(hand: rightCTArrCopy)
            
            if ((leftMax == nil) && (rightMax != nil)) {
                return rightCTArr
            } else if ((rightMax == nil) && (leftMax != nil)) {
                return leftCTArr
            } else if ((leftMax == nil) && (rightMax == nil)) {
                return nil
            } else {
                //Both are non-nil
                let leftMaxRV = leftMax!.rawValue
                let rightMaxRV = rightMax!.rawValue
                
                if (leftMaxRV > rightMaxRV) {
                    return leftCTArr
                } else if (rightMaxRV > leftMaxRV) {
                    return rightCTArr
                }
                
                //CardTypes are equal, so remove them and see if other CardTypes exist
                leftCTArrCopy = HandUtility.remove(cardType: leftMax!, fromArr: leftCTArrCopy)
                rightCTArrCopy = HandUtility.remove(cardType: rightMax!, fromArr: rightCTArrCopy)
            }
        }
    }
    
    static func determineMaxAndHighCardWinner(leftHand: Hand, leftCTArr: [CardType], rightHand: Hand, rightCTArr: [CardType]) -> Hand? {
        let winner = HandUtility.determineMaxWinner(leftCTArr: leftCTArr, rightCTArr: rightCTArr)
        
        if (winner == nil) {
            let newLeftSet = HandUtility.remove(cardTypes: leftCTArr, fromSet: leftHand.cards)
            let newRightSet = HandUtility.remove(cardTypes: rightCTArr, fromSet: rightHand.cards)
            
            let highCardWinner = HighCard.determineWinner(leftHand: HighCard.HighCardFactory(cards: newLeftSet), rightHand: HighCard.HighCardFactory(cards: newRightSet))
            
            if (highCardWinner == nil) {
                return nil
            } else {
                let highCardWinnerSet = highCardWinner!.cards
                if (newLeftSet.isSuperset(of: highCardWinnerSet)) {
                    return leftHand
                } else {
                    return rightHand
                }
            }
        } else if (winner == leftCTArr) {
            return leftHand
        } else {
            return rightHand
        }
    }
    
    static func getDetermineWinnerFunc(fromRank: HandUtility.HandRank) -> HandUtility.SameHandWinnerFunctions {
        var retVal: HandUtility.SameHandWinnerFunctions?
        for (rank, function) in HandUtility.determineWinnerFunctionsArr {
            if (rank == fromRank) {
                retVal = function
                break
            }
        }
        return retVal!
    }
    
    static func handsEqual(lhs: Hand, rhs: Hand) -> Bool {
        return lhs.cards == rhs.cards
    }
}

struct HighCard: Hand {
    let cards: Set<Card>
    let name: String = "High Card"
    static let rank = HandUtility.HandRank.ONE
    
    private init(cards: Set<Card>) {
        self.cards = cards
    }
    
    static func HighCardFactory(cards: Set<Card>) -> HighCard {
        return HighCard(cards: cards)
    }
    
    static func determineWinner(leftHand: HighCard, rightHand: HighCard) -> HighCard? {
        var (leftHandOnly, rightHandOnly) = HandUtility.subtractHands(leftHand: leftHand.cards, rightHand: rightHand.cards)
        
        while (true) {
            let leftMax = HandUtility.getMax(hand: leftHandOnly)
            let rightMax = HandUtility.getMax(hand: rightHandOnly)
            
            if ((leftMax == nil) && (rightMax != nil)) {
                return rightHand
            } else if ((rightMax == nil) && (leftMax != nil)) {
                return leftHand
            } else if ((leftMax == nil) && (rightMax == nil)) {
                return nil
            } else {
                let leftMaxRaw = leftMax!.cardType.rawValue
                let rightMaxRaw = rightMax!.cardType.rawValue
                if (leftMaxRaw > rightMaxRaw) {
                    return leftHand
                } else if (rightMaxRaw > leftMaxRaw) {
                    return rightHand
                } else {
                    leftHandOnly.remove(leftMax!)
                    rightHandOnly.remove(rightMax!)
                }
            }
        }
    }
    
    static func == (lhs: HighCard, rhs: HighCard) -> Bool {
        //        return lhs.cards == rhs.cards
        return HandUtility.handsEqual(lhs: lhs, rhs: rhs)
    }
    
    func getRank() -> HandUtility.HandRank {
        return HighCard.rank
    }
}

struct OnePair: Hand {
    let cards: Set<Card>
    let name: String = "One Pair"
    let onePair: CardType
    let map: [CardType : Int]
    static let rank = HandUtility.HandRank.TWO
    
    private init(cards: Set<Card>, onePair: CardType, map: [CardType : Int]) {
        self.cards = cards
        self.onePair = onePair
        self.map = map
    }
    
    static func OnePairFactory(cards: Set<Card>) -> OnePair? {
        let (compliant, myKeyValues, myMap) = HandUtility.checkCardTypeCompliance(cards: cards, thresholds: 2)
        if (compliant) {
            return OnePair(cards: cards, onePair: myKeyValues![0].0, map: myMap!)
        } else {
            return nil
        }
    }
    
    static func determineWinner(leftHand: OnePair, rightHand: OnePair) -> OnePair? {
        let retVal = HandUtility.determineMaxAndHighCardWinner(leftHand: leftHand, leftCTArr: [leftHand.onePair], rightHand: rightHand, rightCTArr: [rightHand.onePair])
        
        if (retVal == nil) {
            return nil
        } else {
            return retVal as! OnePair?
        }
    }
    
    func getRank() -> HandUtility.HandRank {
        return OnePair.rank
    }
}

struct TwoPair: Hand {
    let cards: Set<Card>
    let name: String = "Two Pairs"
    let twoPairCombos: [CardType]
    let map: [CardType : Int]
    static let rank = HandUtility.HandRank.THREE
    
    private init(cards: Set<Card>, twoPairCombos: [CardType], map: [CardType : Int]) {
        self.cards = cards
        self.twoPairCombos = twoPairCombos
        self.map = map
    }
    
    static func TwoPairFactory(cards: Set<Card>) -> TwoPair? {
        let (compliant, myKeyValues, myMap) = HandUtility.checkCardTypeCompliance(cards: cards, thresholds: 2)
        if (compliant) {
            var tmpTwoPairs = [CardType]()
            if (myKeyValues!.count < 2) {
                return nil
            }
            for (cardType, _) in myKeyValues! {
                tmpTwoPairs.append(cardType)
            }
            return TwoPair(cards: cards, twoPairCombos: tmpTwoPairs, map: myMap!)
        } else {
            return nil
        }
    }
    
    static func determineWinner(leftHand: TwoPair, rightHand: TwoPair) -> TwoPair? {
        let retVal = HandUtility.determineMaxAndHighCardWinner(leftHand: leftHand, leftCTArr: leftHand.twoPairCombos, rightHand: rightHand, rightCTArr: rightHand.twoPairCombos)
        
        if (retVal == nil) {
            return nil
        } else {
            return retVal as! TwoPair?
        }
    }
    
    func getRank() -> HandUtility.HandRank {
        return TwoPair.rank
    }
}

struct ThreeOfAKind: Hand {
    let cards: Set<Card>
    let name: String = "Three of a Kind"
    let threeKindCombos: [CardType]
    let map: [CardType : Int]
    static let rank = HandUtility.HandRank.FOUR
    
    private init(cards: Set<Card>, threeKindCombos: [CardType], map: [CardType : Int]) {
        self.cards = cards
        self.threeKindCombos = threeKindCombos
        self.map = map
    }
    
    static func ThreeOfAKindFactory(cards: Set<Card>) -> ThreeOfAKind? {
        let (compliant, myKeyValues, myMap) = HandUtility.checkCardTypeCompliance(cards: cards, thresholds: 3)
        if (compliant) {
            var tmpThreeCombos = [CardType]()
            for (cardType, _) in myKeyValues! {
                tmpThreeCombos.append(cardType)
            }
            return ThreeOfAKind(cards: cards, threeKindCombos: tmpThreeCombos, map: myMap!)
        } else {
            return nil
        }
    }
    
    static func determineWinner(leftHand: ThreeOfAKind, rightHand: ThreeOfAKind) -> ThreeOfAKind? {
        let retVal = HandUtility.determineMaxAndHighCardWinner(leftHand: leftHand, leftCTArr: leftHand.threeKindCombos, rightHand: rightHand, rightCTArr: rightHand.threeKindCombos)
        
        if (retVal == nil) {
            return nil
        } else {
            return retVal as! ThreeOfAKind?
        }
    }
    
    func getRank() -> HandUtility.HandRank {
        return ThreeOfAKind.rank
    }
}

struct Straight: Hand {
    let cards: Set<Card>
    let name: String = "Straight"
    let actualStraights: [[Card]]
    let highestStraight: [Card]
    static let rank = HandUtility.HandRank.FIVE
    
    private init(cards: Set<Card>, actualStraights: [[Card]]) {
        self.cards = cards
        self.actualStraights = actualStraights
        self.highestStraight = self.actualStraights[self.actualStraights.count - 1]
    }
    
    private init(sortedCards: [Card]) {
        self.cards = Set<Card>(sortedCards)
        var tmpActualStraights = [[Card]]()
        tmpActualStraights.append(sortedCards)
        self.actualStraights = tmpActualStraights
        self.highestStraight = sortedCards
    }
    
    static func StraightFactory(straightFlush: StraightFlush) -> Straight {
        return Straight(sortedCards: straightFlush.actualStraightFlush)
    }
    
    static func StraightFactory(cards: Set<Card>) -> Straight? {
        let (isCompliant, actualStraights) = isInstanceOf(cards: cards)
        if (isCompliant) {
            return Straight(cards: cards, actualStraights: actualStraights!)
        } else {
            return nil
        }
    }
    
    static func isInstanceOf(cards: Set<Card>) -> (isCompliant: Bool, actualStraights: [[Card]]?) {
        //Sort array
        var cardsSorted = HandUtility.cardSorterAsc(cards: cards)
        var toCheck = [[Card]]()
        var toReturn = [[Card]]()
        
        //Check that there are at least 5 cards
        let numCards = cardsSorted.count
        let standardHand = 5
        if (numCards < standardHand) {
            return (false, nil)
        }
        
        //If first card is a Two and last is an Ace, copy the Ace to the front
        let firstCard = cardsSorted[0]
        let lastCard = cardsSorted[numCards - 1]
        var twoAce = false
        if ((firstCard.cardType == CardType.two) && (lastCard.cardType == CardType.ace)) {
            twoAce = true
            cardsSorted.insert(lastCard, at: 0)
        }
        
        //Check sorted array 5 cards at a time.
        let numToCheck = numCards - standardHand + 1
        var straightFound = false
        outerLoop: for x in 0..<numToCheck {
            var outerBound = x + standardHand
            toCheck.append(Array(cardsSorted[x..<outerBound]))
            
            //look for the straight (successive cards increase by 1)
            var count = 0
            var y = 0
            innerLoop: while (y < (toCheck[x].count - 1)) {
                var leftVal = toCheck[x][y].cardType.rawValue
                if (twoAce && (x == 0) && (y == 0)) {
                    leftVal = CardType.two.rawValue - 1
                }
                let rightVal = toCheck[x][y + 1].cardType.rawValue
                
                if (rightVal == (leftVal + 1)) {
                    count = count + 1
                } else {
                    if ((rightVal == leftVal) && (outerBound < cardsSorted.count)) {
                        toCheck[x].append(cardsSorted[outerBound])
                        outerBound = outerBound + 1
                    } else {
                        break innerLoop
                    }
                }
                y = y + 1
            }
            
            if (count == (standardHand - 1)) {
                toReturn.append(toCheck[x])
                straightFound = true
            }
        }
        
        if (straightFound) {
            return (true, toReturn)
        }
        
        return (false, nil)
    }
    
    private func getHighCardValue() -> Int {
        return self.highestStraight[highestStraight.count - 1].cardType.rawValue
    }
    
    static func determineWinner(leftHand: Straight, rightHand: Straight) -> Straight? {
        let leftStraightHighCard = leftHand.getHighCardValue()
        let rightStraightHighCard = rightHand.getHighCardValue()
        
        if (leftStraightHighCard > rightStraightHighCard) {
            return leftHand
        } else if (rightStraightHighCard > leftStraightHighCard) {
            return rightHand
        } else {
            return nil
        }
    }
    
    static func == (lhs: Straight, rhs: Straight) -> Bool {
        return HandUtility.handsEqual(lhs: lhs, rhs: rhs)
    }
    
    func getRank() -> HandUtility.HandRank {
        return Straight.rank
    }
}

struct Flush: Hand {
    let cards: Set<Card>
    let name: String = "Flush"
    let flushCards: Set<Card>
    let map: [Suit : Int]
    static let rank = HandUtility.HandRank.SIX
    
    private init(cards: Set<Card>, flushCards: Set<Card>, map: [Suit : Int]) {
        self.cards = cards
        self.flushCards = flushCards
        self.map = map
    }
    
    static func FlushFactory(cards: Set<Card>) -> Flush? {
        let (compliant, myKeyValues, myMap) = HandUtility.checkSuitCompliance(cards: cards, thresholds: 5)
        if (compliant) {
            var tmpFlush = Set<Card>()
            let suit = myKeyValues![0].0
            for card in cards {
                if (card.suit == suit) {
                    tmpFlush.insert(card)
                }
            }
            return Flush(cards: cards, flushCards: tmpFlush, map: myMap!)
        } else {
            return nil
        }
    }
    
    static func determineWinner(leftHand: Flush, rightHand: Flush) -> Flush? {
        let leftHC = HighCard.HighCardFactory(cards: leftHand.flushCards)
        let rightHC = HighCard.HighCardFactory(cards: rightHand.flushCards)
        
        let winner = HighCard.determineWinner(leftHand: leftHC, rightHand: rightHC)
        
        if (winner == nil) {
            return nil
        } else if (winner! == leftHC) {
            return leftHand
        } else {
            return rightHand
        }
    }
    
    func getRank() -> HandUtility.HandRank {
        return Flush.rank
    }
}

struct FullHouse: Hand {
    let cards: Set<Card>
    let name: String = "Full House"
    let threeKind: CardType
    let onePairs: [CardType]
    let map: [CardType : Int]
    static let rank = HandUtility.HandRank.SEVEN
    
    private init(cards: Set<Card>, threeKind: CardType, onePairs: [CardType], map: [CardType : Int]) {
        self.cards = cards
        self.threeKind = threeKind
        self.onePairs = onePairs
        self.map = map
    }
    
    static func FullHouseFactory(cards: Set<Card>) -> FullHouse? {
        let (compliant, myKeyValues, myMap) = HandUtility.checkCardTypeCompliance(cards: cards, thresholds: 3, 2)
        if (compliant) {
            var tmpOnePairs = [CardType]()
            var tmpThreeKind: CardType!
            for (cardType, count) in myKeyValues! {
                if (count == 3) {
                    tmpThreeKind = cardType
                } else if (count == 2) {
                    tmpOnePairs.append(cardType)
                }
            }
            return FullHouse(cards: cards, threeKind: tmpThreeKind, onePairs: tmpOnePairs, map: myMap!)
        } else {
            return nil
        }
    }
    
    static func determineWinner(leftHand: FullHouse, rightHand: FullHouse) -> FullHouse? {
        let leftThreeKindRV = leftHand.threeKind.rawValue
        let rightThreeKindRV = rightHand.threeKind.rawValue
        
        if (leftThreeKindRV > rightThreeKindRV) {
            return leftHand
        } else if (rightThreeKindRV > leftThreeKindRV) {
            return rightHand
        } else {
            //Three of a Kinds are the same. Now check One Pairs
            let leftOnePairs = leftHand.onePairs
            let rightOnePairs = rightHand.onePairs
            
            let winner = HandUtility.determineMaxWinner(leftCTArr: leftOnePairs, rightCTArr: rightOnePairs)
            
            if (winner == nil) {
                return nil
            } else if (winner == leftOnePairs) {
                return leftHand
            } else {
                return rightHand
            }
        }
    }
    
    func getRank() -> HandUtility.HandRank {
        return FullHouse.rank
    }
}

struct FourOfAKind: Hand {
    let cards: Set<Card>
    let name: String = "Four of a Kind"
    let fourKindCardType: CardType
    let map: [CardType : Int]
    static let rank = HandUtility.HandRank.EIGHT
    
    private init(cards: Set<Card>, fourKindCardType: CardType, map: [CardType : Int]) {
        self.cards = cards
        self.fourKindCardType = fourKindCardType
        self.map = map
    }
    
    static func FourOfAKindFactory(cards: Set<Card>) -> FourOfAKind? {
        let (compliant, myKeyValues, myMap) = HandUtility.checkCardTypeCompliance(cards: cards, thresholds: 4)
        if (compliant) {
            return FourOfAKind(cards: cards, fourKindCardType: myKeyValues![0].0, map: myMap!)
        } else {
            return nil
        }
    }
    
    static func determineWinner(leftHand: FourOfAKind, rightHand: FourOfAKind) -> FourOfAKind {
        let leftCT = leftHand.fourKindCardType.rawValue
        let rightCT = rightHand.fourKindCardType.rawValue
        
        //Hands cannot have the same card type
        if (leftCT > rightCT) {
            return leftHand
        } else {
            return rightHand
        }
    }
    
    func getRank() -> HandUtility.HandRank {
        return FourOfAKind.rank
    }
}

struct StraightFlush: Hand {
    let cards: Set<Card>
    let name: String = "Straight Flush"
    let actualStraightFlush: [Card]
    static let rank = HandUtility.HandRank.NINE
    
    private init(cards: Set<Card>, actualStraightFlush: [Card]) {
        self.cards = cards
        self.actualStraightFlush = actualStraightFlush
    }
    
    static func StraightFlushFactory(cards: Set<Card>) -> StraightFlush? {
        //First, check if a Flush. This order removes any duplicate cards of a different suit
        let tmpFlush = Flush.FlushFactory(cards: cards)
        if (tmpFlush != nil) {
            let (isStraight, straightHands) = Straight.isInstanceOf(cards: tmpFlush!.flushCards)
            if (!isStraight) {
                return nil
            }
            
            //Only concerned with the highest Straight Flush, located at the end of the array
            return StraightFlush(cards: cards, actualStraightFlush: straightHands![straightHands!.count - 1])
        }
        
        return nil
    }
    
    static func determineWinner(leftHand: StraightFlush, rightHand: StraightFlush) -> StraightFlush? {
        let leftStraight = Straight.StraightFactory(straightFlush: leftHand)
        let rightStraight = Straight.StraightFactory(straightFlush: rightHand)
        
        let winner = Straight.determineWinner(leftHand: leftStraight, rightHand: rightStraight)
        
        if (winner == nil) {
            return nil
        } else if (winner! == leftStraight) {
            return leftHand
        } else {
            return rightHand
        }
    }
    
    func getRank() -> HandUtility.HandRank {
        return StraightFlush.rank
    }
}
