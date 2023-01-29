//
//  TableGameViewController.swift
//  FreeTexasHoldEm
//
//  Created by Steven Rothstein on 11/4/18.
//  Copyright © 2018 Steven Rothstein. All rights reserved.
//

import UIKit

class TableGameViewController: UIViewController {
    @IBOutlet var myCard1: UIImageView?
    @IBOutlet var myCard2: UIImageView?
    
    @IBOutlet var player1Card1: UIImageView?
    @IBOutlet var player1Card2: UIImageView?
    
    @IBOutlet var player2Card1: UIImageView?
    @IBOutlet var player2Card2: UIImageView?
    
    @IBOutlet var player3Card1: UIImageView?
    @IBOutlet var player3Card2: UIImageView?
    
    @IBOutlet var player4Card1: UIImageView?
    @IBOutlet var player4Card2: UIImageView?
    
    @IBOutlet var communityCard1: UIImageView?
    @IBOutlet var communityCard2: UIImageView?
    @IBOutlet var communityCard3: UIImageView?
    @IBOutlet var communityCard4: UIImageView?
    @IBOutlet var communityCard5: UIImageView?
    
    @IBOutlet var ccCardSilo1: UIImageView?
    @IBOutlet var ccCardSilo2: UIImageView?
    @IBOutlet var ccCardSilo3: UIImageView?
    @IBOutlet var ccCardSilo4: UIImageView?
    @IBOutlet var ccCardSilo5: UIImageView?
    
    @IBOutlet var deckCard: UIImageView?
    
    @IBOutlet var labelp1: UILabel?
    @IBOutlet var labelp2: UILabel?
    @IBOutlet var labelp3: UILabel?
    @IBOutlet var labelp4: UILabel?
    @IBOutlet var labelMe: UILabel?
    
    @IBOutlet var labelp1Hand: UILabel?
    @IBOutlet var labelp2Hand: UILabel?
    @IBOutlet var labelp3Hand: UILabel?
    @IBOutlet var labelp4Hand: UILabel?
    @IBOutlet var labelMeHand: UILabel?
    
    @IBOutlet var actionLabel: UILabel?
    
    @IBOutlet var dealerChip: UIImageView?
    
    @IBOutlet var continueButton_gameplay: UIButton?
    @IBOutlet var continueButton_betting: UIButton?
    
    @IBOutlet var handActionButtons: [UIButton]!
    
    @IBOutlet var currentPotLabel: UILabel?
    
    @IBOutlet var myRaisePicker: UIPickerView?
    @IBOutlet var myRaisePickerSelectButton: UIButton?
    @IBOutlet var totalBetAmountLabel: UILabel?
    
    var myRaisePickerData = ["10", "20", "30", "40", "50", "60", "70"]
    var myPickerSelection = 0
    var myRaiseOrBet: CardActions? = nil
    
    var handActionButtonLocations: [(x: CGFloat, y: CGFloat)] = []
    
    var playerLabels: [(nameLabel: UILabel, handLabel: UILabel)] = []
    
    var playerCardUIImageViews: [UIImageView] = []
    var playerCardPositionArr: [(CGFloat, CGFloat)] = []
    
    var communityCardUIImageViews: [UIImageView] = []
    var communityCardPositionArr: [(CGFloat, CGFloat)] = []
    
    var ccCardSiloUIImageViews: [UIImageView] = []
    
    let flipDuration = 0.7
    let cardAnimationDuration = 0.5
    let labelAnimationDuration = 1.0
    let foldAnimationDuration = 0.2
    let myDelayIncrease = 0.2
    
    var dealer = Dealer()
    var playersArr = [(tuple_player: Player, tuple_uiview1: UIImageView, tuple_uiview2: UIImageView, tuple_nameLabel: UILabel, tuple_handLabel: UILabel)]()
    var activePlayers = [(tuple_player: Player, tuple_uiview1: UIImageView, tuple_uiview2: UIImageView, tuple_nameLabel: UILabel, tuple_handLabel: UILabel)]()
    
    var firstBet = true
    var notLastPlayerFolded = false
    let acceptableActionsFirstBet = [CardActions.check.rawValue, CardActions.bet.rawValue, CardActions.fold.rawValue]
    var currentBetAmount = 0
    
    var currentPotAmount = 0
    
    var currentBettingIndex = -1
    
    var playerToSkip: Player? = nil
    
    var flopCards: [Card] = []
    var turnCard: Card! = nil
    var riverCard: Card! = nil
    
    var CURRENT_ENTRY_POINT = 0
    
    func retainCoordinatesAndMove(forUIImageViewArr: [UIImageView], toCGFloatArr: inout [(CGFloat, CGFloat)]) {
        //Place all cards on the bottom of the deck in the top right
        for currIndex in forUIImageViewArr {
            toCGFloatArr.append((currIndex.center.x, currIndex.center.y))
            
            currIndex.center.x = deckCard!.center.x
            currIndex.center.y = deckCard!.center.y
        }
    }
    
    func getPlayerUIIndices(fromPlayerLabelNum: Int) -> (uiview1Index: Int, uiview2Index: Int) {
        return (fromPlayerLabelNum, fromPlayerLabelNum + playerLabels.count)
    }
    
    func setDealerChipLocation() {
        var index = self.playersArr.count - 1
        let firstUIView = self.playerCardUIImageViews[index]
        var funcToUse: (CGFloat, CGFloat) -> CGFloat = (-)
        if (firstUIView === player1Card1) || (firstUIView === player2Card1) {
            index = self.getPlayerUIIndices(fromPlayerLabelNum: index).uiview2Index
            funcToUse = (+)
        }

        let (x, y) = self.playerCardPositionArr[index]
        dealerChip!.center.y = y
        let firstOperand = x
        
        dealerChip!.center.x = funcToUse(funcToUse(funcToUse(firstOperand, firstUIView.frame.width / 2),(dealerChip!.frame.width / 2)), 5)
    }
    
    //Second function to execute
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set up winner label and make it invisible
        actionLabel!.layer.cornerRadius = 10.0
        actionLabel!.clipsToBounds = true
        actionLabel!.alpha = 0
        wordWrapLabel(label: actionLabel!)
        
        //Make the Dealer Chip and continue button invisible
        self.dealerChip!.alpha = 0
        self.continueButton_gameplay!.alpha = 0
        self.continueButton_betting!.alpha = 0
        
        //Make the picker components invisible
        self.myRaisePickerSelectButton!.alpha = 0
        self.myRaisePicker!.alpha = 0
        self.totalBetAmountLabel!.alpha = 0
        wordWrapLabel(label: self.totalBetAmountLabel!)
        
        //Make the Hand Action buttons invisible and set their text
        let cardActions = CardActions.allCases
        for x in 0..<self.handActionButtons.count {
            let handActionButton = self.handActionButtons[x]
            handActionButton.alpha = 0
            handActionButton.setTitle(cardActions[x].getStringValue(), for: .normal)
            
            //Hold the original locations so the buttons can be placed when necessary
            handActionButtonLocations.append((handActionButton.center.x, handActionButton.center.y))
        }
        
        //Set up the individual Player objects
        //Set up the Player Labels
        for i in 0..<playerLabels.count {
            var myName = "Player \(i + 1)"
            var myIsComputer = true
            
            if (i == (playerLabels.count - 1)) {
                myName = "Me"
                myIsComputer = false
            }
            
            let currTuple = playerLabels[i]
            let currNameLabel = currTuple.nameLabel
            let currHandLabel = currTuple.handLabel
            
            wordWrapLabel(label: currNameLabel)
            changeText(forLabel: currNameLabel, to: myName)
            
            //Make the player label invisible. It will appear later in an animation.
            currNameLabel.alpha = 0
            currHandLabel.alpha = 0
            
            //Center the Player label between the 2 cards for that player
            let (index1, index2) = getPlayerUIIndices(fromPlayerLabelNum: i)
            let tmpCardView = playerCardUIImageViews[index1]
            let startX = tmpCardView.frame.minX
            let endX = playerCardUIImageViews[index2].frame.maxX
            let newX = startX + ((endX - startX) / 2)
            currNameLabel.center.x = newX
            
            //Place the label below the cards
            currNameLabel.center.y = tmpCardView.frame.maxY + 1
            
            playersArr.append((Player(isComputer: myIsComputer, name: myName), playerCardUIImageViews[index1], playerCardUIImageViews[index2], currNameLabel, currHandLabel))
        }
        
        //Make the silo invisible. It will appear later in an animation.
        for silo in ccCardSiloUIImageViews {
            silo.alpha = 0
        }
        
        //Move the cards to the "Deck" in the top right and retain their original coordinates
        retainCoordinatesAndMove(forUIImageViewArr: playerCardUIImageViews, toCGFloatArr: &playerCardPositionArr)
        retainCoordinatesAndMove(forUIImageViewArr: communityCardUIImageViews, toCGFloatArr: &communityCardPositionArr)
        
        //Place the dealer chip
        self.setDealerChipLocation()
    }
    
    func playGame() {
        if (self.CURRENT_ENTRY_POINT == 0) {
            var tmpMyCards = [Card]()
            
            self.activePlayers = []
            
            for (player, uiview1, uiview2, nameLabel, handLabel) in playersArr {
                let currentCards = dealer.deck.takeFromTop(numCards: 2)
                player.addCardsToHand(cards: currentCards)
                if (!player.isComputer) {
                    tmpMyCards = currentCards
                }
                self.activePlayers.append((player.copyPlayer(), uiview1, uiview2, nameLabel, handLabel))
            }
            
            //Bring the player's cards' UIImageViews to the top of the deck in reverse order
            //Needed for animation to work properly when moving from deck to center
            bringArrayToFrontInReverse(array: self.playerCardUIImageViews)
            
            //Animate the cards to their positions
            UIView.animate(withDuration: 1.5) {
                for silo in self.ccCardSiloUIImageViews {
                    silo.alpha = 1
                }
            }
            
            var myDelay = 0.0
            let endRange = playerCardUIImageViews.count
            for currIndex in 0..<endRange {
                let currImage = playerCardUIImageViews[currIndex]
                
                //Flip the user's cards (non-computer player)
                var flipClosure: ((Bool) -> Void)? = nil
                
                let isMyCards = ((currImage === myCard1) || (currImage === myCard2))
                if (isMyCards) {
                    flipClosure = getFlipUpClosure(fromImage: currImage, fromCard: tmpMyCards.popLast()!)
                }
                
                UIView.animate(withDuration: cardAnimationDuration, delay: myDelay, options: [], animations: {
                    if (currIndex == 0) {
                        //Move dealer chip
                        self.dealerChip!.alpha = 1
                        self.setDealerChipLocation()
                    }
                    
                    let (myX, myY) = self.playerCardPositionArr[currIndex]
                    currImage.center.x = myX
                    currImage.center.y = myY
                    
                    //Animate the Player's label to appear
                    if (currIndex < self.playerLabels.count) {
                        self.playerLabels[currIndex].nameLabel.alpha = 1
                    }
                }, completion: {
                    (value: Bool) in
                    
                    let shouldFlip = flipClosure != nil
                    if (shouldFlip) {
                        flipClosure!(true)
                    }
                    
                    if (currIndex == (endRange - 1)) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.flipDuration, execute: {
                            self.firstBet = true
                            self.showContinueButton(myButton: self.continueButton_betting!)
                        })
                    }
                })
                
                myDelay = myDelay + myDelayIncrease
            }
        }
            
        else if (self.CURRENT_ENTRY_POINT == 1) {
            //Bring the community cards' UIImageViews to the top of the deck in reverse order
            //Needed for animation to work properly when moving from deck to center
            self.bringArrayToFrontInReverse(array: self.communityCardUIImageViews)
            
            self.flopCards = self.dealer.deck.takeFromTop(numCards: 3)
            self.animateCommunityCards(cards: self.flopCards)
        }
            
        else if (self.CURRENT_ENTRY_POINT == 2) {
            for (activePlayer, _, _, _, _) in self.activePlayers {
                activePlayer.addCardsToHand(cards: self.flopCards)
            }
            
            self.firstBet = true
            self.showContinueButton(myButton: self.continueButton_betting!)
        }
            
        else if (self.CURRENT_ENTRY_POINT == 3) {
            turnCard = dealer.deck.takeFromTop(numCards: 1)[0]
            self.animateCommunityCard(card: turnCard, ccIndex: 3)
        }
            
        else if (self.CURRENT_ENTRY_POINT == 4) {
            for (activePlayer, _, _, _, _) in self.activePlayers {
                activePlayer.addCardToHand(card: self.turnCard)
            }
            
            self.firstBet = true
            self.showContinueButton(myButton: self.continueButton_betting!)
        }
            
        else if (self.CURRENT_ENTRY_POINT == 5) {
            riverCard = dealer.deck.takeFromTop(numCards: 1)[0]
            self.animateCommunityCard(card: riverCard, ccIndex: 4)
        }
            
        else if (self.CURRENT_ENTRY_POINT == 6) {
            for (activePlayer, _, _, _, _) in self.activePlayers {
                activePlayer.addCardToHand(card: self.riverCard)
            }
            
            self.firstBet = true
            self.showContinueButton(myButton: self.continueButton_betting!)
        }
            
        else if (self.CURRENT_ENTRY_POINT == 7) {
            moveAndFlipCards(shouldFlipUp: true)
        }
            
        else if (self.CURRENT_ENTRY_POINT == 8) {
            var tmpPlayers = [Player]()
            for (player, _, _, _, _) in self.activePlayers {
                tmpPlayers.append(player)
            }
            let (allHandOutcomes, winningPlayers) = self.determineWinner(fromPlayers: tmpPlayers)
            var startString = ""
            if (winningPlayers.count > 1) {
                startString = "The following players split the pot:"
                for winner in winningPlayers {
                    startString += "\n\(winner.0.name)"
                }
            } else {
                let winningPlayer = winningPlayers[0].0
                startString = winningPlayer.isComputer ? "\(winningPlayer.name) wins!" : "You win!"
            }
            
            let endString = "\n\nHand: " + winningPlayers[0].1.name
            
            self.changeActionLabelText(to: startString + endString)
            
            for x in 0..<self.activePlayers.count {
                let currTuple = self.activePlayers[x]
                let currHandLabel = currTuple.tuple_handLabel
                let currNameLabel = currTuple.tuple_nameLabel
                
                self.changeText(forLabel: currHandLabel, to: allHandOutcomes[x].1.name)
                currHandLabel.center.x = currNameLabel.center.x
                currHandLabel.center.y = currNameLabel.center.y + currNameLabel.frame.height - 3
            }
            
            self.view.bringSubviewToFront(self.actionLabel!)
            
            UIView.animate(withDuration: self.labelAnimationDuration, animations: {
                self.actionLabel!.alpha = 1
                
                for (_, _, _, _, handLabel) in self.activePlayers {
                    handLabel.alpha = 1
                }
            }, completion: {
                (value: Bool) in
                self.showContinueButton(myButton: self.continueButton_gameplay!)
            })
        }
            
        else if (self.CURRENT_ENTRY_POINT == 9) {
            UIView.animate(withDuration: self.labelAnimationDuration, animations: {
                self.actionLabel!.alpha = 0
            }, completion: {
                (value: Bool) in
                self.moveAndFlipCards(shouldFlipUp: false)
            })
        }
            
        else if (self.CURRENT_ENTRY_POINT == 10) {
            for card in (self.communityCardUIImageViews + [self.myCard1!, self.myCard2!]) {
                self.getFlipDownClosure(fromImage: card)!(true)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.flipDuration, execute: {
                let allImageViews = self.communityCardUIImageViews + self.playerCardUIImageViews
                
                UIView.animate(withDuration: self.cardAnimationDuration, animations: {
                    for imageview in allImageViews {
                        imageview.center.x = self.deckCard!.center.x
                        imageview.center.y = self.deckCard!.center.y
                    }
                    
                    for (playerLabel, handLabel) in self.playerLabels {
                        playerLabel.alpha = 0
                        handLabel.alpha = 0
                    }
                }, completion: {
                    (value: Bool) in
                    self.showContinueButton(myButton: self.continueButton_gameplay!)
                })
            })
        }
        
        else if (self.CURRENT_ENTRY_POINT == 11) {
            //Reset the deck (creates a new deck and shuffles it)
            self.dealer = Dealer()
            
            //Clear the cards from each player's hand
            for (player, _, _, _, _) in self.playersArr {
                player.clearHand()
            }
            
            self.currentPotAmount = 0
            self.setPotLabelText()
            
            //Rearrange arrays to move dealer to the next player
            self.popFirstAndAddToEnd(array: &self.playerLabels)
            self.popFirstAndAddToEnd(array: &self.playersArr)
            
            self.swapAndPopFirstAndAddToEnd(array: &self.playerCardUIImageViews)
            self.swapAndPopFirstAndAddToEnd(array: &self.playerCardPositionArr)
            
            self.CURRENT_ENTRY_POINT = -1
            self.playContinue()
        }
    }
    
    func changeActionLabelText(to: String) {
        self.changeText(forLabel: self.actionLabel!, to: to)
        self.placeActionLabelOnScreen()
    }
    
    func placeActionLabelOnScreen() {
        let padding: CGFloat = 40
        self.actionLabel!.frame.size.width = self.actionLabel!.frame.width + padding
        self.actionLabel!.frame.size.height = self.actionLabel!.frame.height + padding
        
        let screenBounds = UIScreen.main.bounds
        self.actionLabel!.center.x = screenBounds.width / 2
        self.actionLabel!.center.y += self.getOffsetForLabels(num1: self.actionLabel!.frame.minY, num2: self.player2Card1!.frame.minY, padding: 10)
    }
    
    func swapAndPopFirstAndAddToEnd<T>(array: inout [T]) {
        let (index1, index2) = self.getPlayerUIIndices(fromPlayerLabelNum: 0)
        
        let tmpForSwap = array[index2]
        array[index2] = array[index1]
        array[index1] = tmpForSwap
        self.popFirstAndAddToEnd(array: &array)
    }
    
    func popFirstAndAddToEnd<T>(array: inout [T]) {
        array.append(array.removeFirst())
    }
    
    //Third function to execute
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.playGame()
    }
    
    func showContinueButton(myButton: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            myButton.alpha = 1
        }, completion: nil)
    }
    
    func bet(player: Player, amount: Int, bettingContinueHuman: Bool = false) {
        self.currentBetAmount = amount
        call(player: player, bettingContinueHuman: bettingContinueHuman)
    }
    
    func call(player: Player, bettingContinueHuman: Bool = false) {
        let callAmount = self.currentBetAmount - player.getCurrentBet()
        self.currentPotAmount += callAmount
        player.raiseCurrentBet(raiseAmount: callAmount)
        self.setPotLabelText()
        
        if (bettingContinueHuman) {
            self.continueBetting(fromHumanPlayer: true)
        }
    }
    
    func raise(player: Player, amount: Int) {
        self.currentBetAmount += amount
        player.raiseCurrentBet(raiseAmount: amount)
        self.currentPotAmount += self.currentBetAmount
        self.setPotLabelText()
        
        self.resetActivePlayersIndex()
        self.playerToSkip = player
        self.bettingPlayContinue()
    }
    
    func fold(playerTuple: (Player, UIImageView, UIImageView, UILabel, UILabel)) {
        let currentPlayer = playerTuple.0
        currentPlayer.clearCurrentBet()
       
        let tmpcount = self.activePlayers.count
        for index in 0..<tmpcount {
            let activePlayerTuple = self.activePlayers[index]
            if (activePlayerTuple.tuple_player === currentPlayer) {
                if (index == 0) {
                    self.firstBet = true
                }
                
                if (index <= (tmpcount - 2)) {
                    self.notLastPlayerFolded = true
                }
                self.activePlayers.remove(at: index)
                break
            }
        }
        
        let uiview1 = playerTuple.1
        var direction: ScreenDirection! = nil
        if (uiview1 === player1Card1) {
            direction = ScreenDirection.left
        } else if (uiview1 === player4Card1) {
            direction = ScreenDirection.right
        } else if (uiview1 === myCard1) {
            direction = ScreenDirection.bottom
        } else {
            direction = ScreenDirection.top
        }
        
        self.moveOffScreen(myView: playerTuple.1, direction: direction)
        self.moveOffScreen(myView: playerTuple.2, direction: direction)
        self.makeInvisible(myView: playerTuple.3)
        self.makeInvisible(myView: playerTuple.4)
    }
    
    func makeInvisible(myView: UIView) {
        UIView.animate(withDuration: self.foldAnimationDuration) {
            myView.alpha = 0
        }
    }
    
    func moveOffScreen(myView: UIView, direction: ScreenDirection) {
        UIView.animate(withDuration: self.foldAnimationDuration) {
            switch (direction) {
            case .bottom:
                myView.center.y += self.view.bounds.height
            case .left:
                myView.center.x -= self.view.bounds.width
            case .right:
                myView.center.x += self.view.bounds.width
            case .top:
                myView.center.y -= self.view.bounds.height
            }
        }
    }
    
    func check(player: Player) {
        
    }
    
    func setPotLabelText() {
        self.currentPotLabel!.text = "Pot Amount: \(self.currentPotAmount)"
    }
    
    func activePlayersHasNext() -> Bool {
        return (self.currentBettingIndex < (self.activePlayers.count - 1))
    }
    
    func resetActivePlayersIndex() {
        self.currentBettingIndex = -1
    }
    
    @IBAction func handActionButtonClick(_ sender: UIButton) {
        for myButton in self.handActionButtons {
            myButton.alpha = 0
        }
        
        let currentTag = sender.tag
        let cardActions = CardActions.allCases
        let chosenAction = cardActions[currentTag]
        
        var shouldContinueNow = true
        
        for currTuple in self.activePlayers {
            if (currTuple.tuple_uiview1 === myCard1) {
                switch (chosenAction) {
                case .check:
                    self.check(player: currTuple.tuple_player)
                case .call:
                    self.call(player: currTuple.tuple_player)
                case .raise, .bet:
                    shouldContinueNow = false
                    self.myRaiseOrBet = chosenAction
                    
                    self.view.bringSubviewToFront(self.myRaisePicker!)
                    self.view.bringSubviewToFront(self.myRaisePickerSelectButton!)
                    self.view.bringSubviewToFront(self.totalBetAmountLabel!)
                    self.resetCurrentBetLabel()
                    self.totalBetAmountLabel!.center.x = UIScreen.main.bounds.width / 2
                    UIView.animate(withDuration: self.cardAnimationDuration) {
                        self.totalBetAmountLabel!.alpha = 1
                        self.myRaisePickerSelectButton!.alpha = 1
                        self.myRaisePicker!.alpha = 1
                    }
                case .fold:
                    self.fold(playerTuple: currTuple)
//                case .bet:
//                    self.bet(player: currTuple.tuple_player, amount: 20)
                }
                
                break
            }
        }
        
        if (shouldContinueNow) {
            self.continueBetting(fromHumanPlayer: true)
        }
    }
    
    func resetCurrentBetLabel() {
        self.changeText(forLabel: self.totalBetAmountLabel!, to: "Call Amount: \(self.currentBetAmount)")
    }
    
    @IBAction func selectPickerButtonChosen() {
        self.totalBetAmountLabel!.alpha = 0
        self.myRaisePickerSelectButton!.alpha = 0
        self.myRaisePicker!.alpha = 0
        
        for currTuple in self.activePlayers {
            if (currTuple.tuple_uiview1 === myCard1) {
                self.raise(player: currTuple.tuple_player, amount: self.myPickerSelection)
                break
            }
        }
    }
    
    //Button action that gets called when betting button clicked
    @IBAction func bettingPlayContinue() {
        //Make the button disappear to prevent duplicate actions
        self.continueButton_betting!.alpha = 0
        
        //Animate the previous action away
        if (self.actionLabel!.alpha == 1) {
            UIView.animate(withDuration: self.labelAnimationDuration) {
                self.actionLabel!.alpha = 0
            }
        }
        
        if (self.activePlayersHasNext() || self.notLastPlayerFolded) {
            if (self.notLastPlayerFolded) {
                self.notLastPlayerFolded = false
            } else {
                self.currentBettingIndex += 1
            }
            let currentPlayer = activePlayers[self.currentBettingIndex].tuple_player
            
            if ((self.playerToSkip != nil) && self.playerToSkip! === currentPlayer) {
                self.playerToSkip = nil
                self.bettingPlayContinue()
            }
            else {
                let isNotComputer = !currentPlayer.isComputer
                
                //If it is the human user, show the action buttons, NOT the betting button
                if (isNotComputer) {
                    var buttonsToShow: [UIButton] = []
                    if (self.firstBet) {
                        for x in 0..<self.acceptableActionsFirstBet.count {
                            var buttonToAdd: UIButton! = nil
                            for tmpButton in self.handActionButtons {
                                if (tmpButton.tag == self.acceptableActionsFirstBet[x]) {
                                    buttonToAdd = tmpButton
                                    break
                                }
                            }
                            buttonsToShow.append(buttonToAdd)
                        }
                        
                        self.firstBet = false
                    } else {
                        for x in 0..<self.handActionButtons.count - 1 {
                            var shouldAdd = true
                            
                            let currentButton = self.handActionButtons[x]
                            var currentTitle: String! = currentButton.title(for: .normal)
                            if (currentTitle == CardActions.call.getStringValue()) {
                                if (canCheck()) {
                                    shouldAdd = false
                                } else {
                                    currentTitle += ": \(self.currentBetAmount - currentPlayer.getCurrentBet())"
                                    currentButton.setTitle(currentTitle, for: .normal)
                                }
                            } else if (currentTitle == CardActions.check.getStringValue()) {
                                if (!canCheck()) {
                                    shouldAdd = false
                                }
                            }
                            
                            if (shouldAdd) {
                                buttonsToShow.append(currentButton)
                            }
                        }
                    }
                    
                    for y in 0..<buttonsToShow.count {
                        let coords = self.handActionButtonLocations[y]
                        let currButton = buttonsToShow[y]
                        currButton.center.x = coords.x
                        currButton.center.y = coords.y
                    }
                    
                    UIView.animate(withDuration: self.cardAnimationDuration, animations: {
                        for handActionButton in buttonsToShow {
                            handActionButton.alpha = 1
                        }
                    }, completion: nil)
                }
                else {
                    //If it is NOT the human user, show the action label and check for next iteration
                    var newText = "\(currentPlayer.name) "
                    if (firstBet) {
                        let betAmount = 40
                        self.bet(player: currentPlayer, amount: betAmount)
                        firstBet = false
                        
                        newText += CardActions.bet.getStringValue().lowercased() + "s \(betAmount)"
                    } else {
                        let oldBet = currentPlayer.getCurrentBet()
                        self.call(player: currentPlayer)
                        newText += CardActions.call.getStringValue().lowercased() + "s \(self.currentBetAmount - oldBet)"
                    }
                    
                    self.changeActionLabelText(to: newText)
                    
                    UIView.animate(withDuration: self.cardAnimationDuration, animations: {
                        self.actionLabel!.alpha = 1
                    }, completion: {
                        (value: Bool) in
                        self.continueBetting(fromHumanPlayer: false)
                    })
                }
            }
        } else {
            self.continueBetting(fromHumanPlayer: false)
        }
    }
    
    func continueBetting(fromHumanPlayer: Bool) {
        if (!self.activePlayersHasNext() || self.notLastPlayerFolded) {
            //If the label is still present, loop back to make it disappear on button click and then play will advance
            if ((actionLabel!.alpha == 1) || self.notLastPlayerFolded) {
                showContinueButton(myButton: self.continueButton_betting!)
            } else {
                for (player, _, _, _, _) in activePlayers {
                    player.clearCurrentBet()
                }
                
                self.currentBetAmount = 0
                
                self.resetActivePlayersIndex()
                playContinue()
            }
        } else {
            if (fromHumanPlayer) {
                bettingPlayContinue()
            } else {
                showContinueButton(myButton: self.continueButton_betting!)
            }
        }
    }
    
    func canCheck() -> Bool {
        return self.currentBetAmount == 0
    }
    
    @IBAction func playContinue() {
        self.continueButton_gameplay!.alpha = 0
        self.CURRENT_ENTRY_POINT += 1
        self.playGame()
    }
    
    func moveAndFlipCards(shouldFlipUp: Bool) {
        //Move the second player card out from under the first player card
        //Then, flip both cards
        //Finally, bring the second card to the top and move it over the first card
        let endRange = playersArr.count
        let lastIndexIsHuman = !(playersArr[endRange - 1].0.isComputer)
        var lastAnimationIndex = (endRange - 1)
        if (lastIndexIsHuman) {
            lastAnimationIndex -= 1
        }
        
        for x in 0..<endRange {
            let (currPlayer, uiview1, uiview2, _, _) = playersArr[x]
            let isComputer = currPlayer.isComputer
            let moveAmount = isComputer ? uiview1.frame.maxX - uiview2.frame.minX + 4 : 0
            UIView.animate(withDuration: self.cardAnimationDuration, delay: 0.0, options: [], animations: {
                uiview2.center.x += moveAmount
            }, completion: {
                (value: Bool) in
                if (isComputer) {
                    if (shouldFlipUp) {
                        let currCards = [Card](currPlayer.getHand())
                        self.getFlipUpClosure(fromImage: uiview1, fromCard: currCards[0])!(true)
                        self.getFlipUpClosure(fromImage: uiview2, fromCard: currCards[1])!(true)
                    } else {
                        self.getFlipDownClosure(fromImage: uiview1)!(true)
                        self.getFlipDownClosure(fromImage: uiview2)!(true)
                    }
                }
                UIView.animate(withDuration: self.cardAnimationDuration, delay: 1, options: [], animations: {
                    self.view.bringSubviewToFront(uiview2)
                    if (shouldFlipUp) {
                        uiview2.center.x -= moveAmount
                    }
                }, completion: {
                    (value: Bool) in
                    if (x == lastAnimationIndex) {
                        self.playContinue()
                    }
                })
            })
        }
    }
    
    func getOffsetForLabels(num1: CGFloat, num2: CGFloat, padding: CGFloat) -> CGFloat {
        return (-1 * (num1 - num2)) + padding
    }
    
    func wordWrapLabel(label: UILabel) {
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
    }
    
    func changeText(forLabel: UILabel, to: String) {
        forLabel.text = to
        forLabel.sizeToFit()
    }
    
    func bringArrayToFrontInReverse(array: [UIImageView]) {
        for x in stride(from: array.count - 1, through: 0, by: -1) {
            self.view.bringSubviewToFront(array[x])
        }
    }
    
    func animateCommunityCards(cards: [Card]) {
        var delay = 0.0
        let endRange = cards.count
        
        var showContinueButton = false
        for x in 0..<endRange {
            if (x == (endRange - 1)) {
                showContinueButton = true
            }
            
            delay = delay + myDelayIncrease
            animateCommunityCard(card: cards[x], ccIndex: x, myDelay: delay, showContinueButton: showContinueButton)
        }
    }
    
    func animateCommunityCard(card: Card, ccIndex: Int, myDelay: Double = 0.0, showContinueButton: Bool = true) {
        let currImage = self.communityCardUIImageViews[ccIndex]
        
        //Flip the card
        let flipClosure = self.getFlipUpClosure(fromImage: currImage, fromCard: card)
        
        UIView.animate(withDuration: self.cardAnimationDuration, delay: myDelay, options: [], animations: {
            let (myX, myY) = self.communityCardPositionArr[ccIndex]
            currImage.center.x = myX
            currImage.center.y = myY
        }, completion: {
            (value: Bool) in
            self.ccCardSiloUIImageViews[ccIndex].alpha = 0
            flipClosure!(true)
            if (showContinueButton) {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.flipDuration, execute: {
                    self.playContinue()
                })
            }
        })
    }
    
    //First function to execute
    //Set up the parallel outlet arrays
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myRaisePicker!.dataSource = self
        self.myRaisePicker!.delegate = self
        
        playerLabels = [(labelp1!, labelp1Hand!), (labelp2!, labelp2Hand!), (labelp3!, labelp3Hand!), (labelp4!, labelp4Hand!), (labelMe!, labelMeHand!)]
        
        playerCardUIImageViews = [player1Card1!, player2Card1!, player3Card1!, player4Card1!, myCard1!, player1Card2!, player2Card2!, player3Card2!, player4Card2!, myCard2!]
        
        communityCardUIImageViews = [communityCard1!, communityCard2!, communityCard3!, communityCard4!, communityCard5!]
        
        ccCardSiloUIImageViews = [ccCardSilo1!, ccCardSilo2!, ccCardSilo3!, ccCardSilo4!, ccCardSilo5!]
        
        handActionButtons = handActionButtons.sorted(by: { $0.tag < $1.tag})
    }
    
    private func getFlipClosure(fromImage: UIImageView, fromUIImage: UIImage?) -> ((Bool) -> Void)? {
        let flipClosure: ((Bool) -> Void)? = {
            (value: Bool) in
            fromImage.image = fromUIImage
            UIView.transition(with: fromImage, duration: self.flipDuration, options: .transitionFlipFromRight, animations: nil, completion: nil)
        }
        
        return flipClosure
    }
    
    func getFlipDownClosure(fromImage: UIImageView) -> ((Bool) -> Void)? {
        let newImage = UIImage(named: "CardBack2")
        return getFlipClosure(fromImage: fromImage, fromUIImage: newImage)
    }
    
    func getFlipUpClosure(fromImage: UIImageView, fromCard: Card) -> ((Bool) -> Void)? {
        return getFlipClosure(fromImage: fromImage, fromUIImage: self.getUIImage(fromCard: fromCard))
    }
    
    func getUIImage(fromCard: Card) -> UIImage? {
        return UIImage(named: "\(fromCard.cardType)_\(fromCard.suit)")
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func determineHandType(player: Player) -> Hand {
        var retVal: Hand?
        let cards = player.getHand()
        
        let arr = HandUtility.factoryFunctionsArr
        let count = arr.count
        for x in 0..<count {
            let tmpEnum = HandUtility.factoryFunctionsArr[x]
            switch tmpEnum {
            case .HIGHCARD(let function):
                return function(cards)
            case .ONEPAIR(let function):
                retVal = function(cards)
            case .TWOPAIR(let function):
                retVal = function(cards)
            case .THREEOFAKIND(let function):
                retVal = function(cards)
            case .STRAIGHT(let function):
                retVal = function(cards)
            case .FLUSH(let function):
                retVal = function(cards)
            case .FULLHOUSE(let function):
                retVal = function(cards)
            case .FOUROFAKIND(let function):
                retVal = function(cards)
            case .STRAIGHTFLUSH(let function):
                retVal = function(cards)
            }
            
            if (retVal != nil) {
                break
            }
        }
        return retVal!
    }
    
    func determineWinner(fromPlayers: [Player]) -> (allPlayers: [(Player, Hand)], winningPlayers: [(Player, Hand)]) {
        var retAllPlayers = [(Player, Hand)]()
        
        var rankArr = [(tuple_rank: HandUtility.HandRank, tuple_hand: Hand, tuplePlayer: Player)]()
        for player in fromPlayers {
            let hand = determineHandType(player: player)
            rankArr.append((hand.getRank(), hand, player))
            retAllPlayers.append((player, hand))
        }
        
        rankArr.sort(by: { $0.tuple_rank.rawValue > $1.tuple_rank.rawValue })
        var maxRankArr = [(tuple_hand: Hand, tuple_player: Player)]()
        let tmpMax = rankArr[0]
        let maxRanking = tmpMax.tuple_rank
        maxRankArr.append((tmpMax.tuple_hand, tmpMax.tuplePlayer))
        
        for x in 1..<rankArr.count {
            let current = rankArr[x]
            let currentRank = current.tuple_rank.rawValue
            if (currentRank != maxRanking.rawValue) {
                break
            }
            
            maxRankArr.append((current.tuple_hand, current.tuplePlayer))
        }
        
        let tmpEnum = HandUtility.getDetermineWinnerFunc(fromRank: maxRanking)
        
        var y = 0
        while (y < (maxRankArr.count - 1)) {
            //if nil, move to next pair, keep both in array
            let tmpWinner: Hand?
            let leftHand = maxRankArr[y].tuple_hand
            let rightHand = maxRankArr[y + 1].tuple_hand
            
            switch tmpEnum {
            case .HIGHCARD(let function):
                tmpWinner = function(leftHand as! HighCard, rightHand as! HighCard)
            case .ONEPAIR(let function):
                tmpWinner = function(leftHand as! OnePair, rightHand as! OnePair)
            case .TWOPAIR(let function):
                tmpWinner = function(leftHand as! TwoPair, rightHand as! TwoPair)
            case .THREEOFAKIND(let function):
                tmpWinner = function(leftHand as! ThreeOfAKind, rightHand as! ThreeOfAKind)
            case .STRAIGHT(let function):
                tmpWinner = function(leftHand as! Straight, rightHand as! Straight)
            case .FLUSH(let function):
                tmpWinner = function(leftHand as! Flush, rightHand as! Flush)
            case .FULLHOUSE(let function):
                tmpWinner = function(leftHand as! FullHouse, rightHand as! FullHouse)
            case .FOUROFAKIND(let function):
                tmpWinner = function(leftHand as! FourOfAKind, rightHand as! FourOfAKind)
            case .STRAIGHTFLUSH(let function):
                tmpWinner = function(leftHand as! StraightFlush, rightHand as! StraightFlush)
            }
            
            if (tmpWinner == nil) {
                y = y + 1
                continue
            } else {
                let indexToRemove = y + 1
                if (HandUtility.handsEqual(lhs: tmpWinner!, rhs: leftHand)) {
                    maxRankArr.remove(at: indexToRemove)
                } else {
                    //The right hand won. All before were losers that should removed.
                    maxRankArr.removeFirst(indexToRemove)
                    //Reset y to 0. The winner is now the first item in the array.
                    y = 0
                }
            }
        }
        
        var retWinners = [(Player, Hand)]()
        for i in 0..<maxRankArr.count {
            retWinners.append((maxRankArr[i].tuple_player, maxRankArr[i].tuple_hand))
        }
        return (retAllPlayers, retWinners)
    }
}

enum ScreenDirection {
    case top, bottom, left, right
}

extension TableGameViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 1 column in picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.myRaisePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: self.myRaisePickerData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.myPickerSelection = Int(self.myRaisePickerData[row])!
        resetCurrentBetLabel()
        let tmptext = self.totalBetAmountLabel!.text
        self.changeText(forLabel: self.totalBetAmountLabel!, to: tmptext! + "\nNew Bet: \(self.myPickerSelection + self.currentBetAmount)")
    }
}
