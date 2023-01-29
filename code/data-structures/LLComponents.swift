//
//  LinkedListComponents.swift
//  TexasHoldem
//
//  Created by Steven Rothstein on 10/19/18.
//  Copyright © 2018 Steven Rothstein. All rights reserved.
//

import Foundation

struct MyIterator<Element: AnyObject> {
    let linkedList: CircularLinkedList<Element>
    private var currentNode: Node<Element>
    private var iterStarted: Bool = false
    
    init(linkedList: CircularLinkedList<Element>) {
        self.linkedList = linkedList
        self.currentNode = self.linkedList.dealer
    }
    
    mutating func reset() {
        self.iterStarted = false
        self.currentNode = self.linkedList.dealer
    }
    
    func removeCurrentNode() {
        if (iterStarted) {
            linkedList.remove(node: currentNode.getPrevious()!)
        }
    }
    
    func hasNext() -> Bool {
        //Will fail if used on a LinkedList initialized with 1 item and never changed
        if (!iterStarted) {
            return true
        }
        if (currentNode === linkedList.dealer) {
            return false
        }
        return true
    }
    
    mutating func next() -> Element? {
        var retVal: Element? = nil
        if (hasNext()) {
            retVal = currentNode.getValue()
            currentNode = currentNode.getNext()!
            iterStarted = true
        }
        return retVal
    }
}

class CircularLinkedList<Element: AnyObject> {
    fileprivate var dealer: Node<Element>
    private var size: Int
//    private var origDealer: Node<Element>
    
    convenience init(elements: Element...) {
        self.init(elementsArr: elements)
    }
    
    init(elementsArr: [Element]) {
        self.dealer = Node<Element>(value: elementsArr[0])
//        self.origDealer = dealer
        self.size = elementsArr.count
        for x in 1..<size {
            addToEnd(newElement: elementsArr[x])
        }
    }
    
    func getCurrentDealer() -> Element {
        return dealer.getValue()
    }
    
    func addToEnd(newElement: Element) {
        var current = dealer
        var currentNext = current.getNext()
        //if statement needed because when first element inserted, its "next" is nil
        if (currentNext != nil) {
            while (currentNext !== dealer) {
                current = currentNext!
                currentNext = current.getNext()
            }
        }
        
        current.setNext(newNext: Node<Element>(value: newElement))
        let next = current.getNext()
        next!.setPrevious(newPrev: current)
        next!.setNext(newNext: dealer)
        dealer.setPrevious(newPrev: next)
    }
    
    //fileprivate so only Iterator can safely remove an element
    fileprivate func remove(node: Node<Element>) {
        let currPrev = node.getPrevious()
        let currNext = node.getNext()
        currPrev!.setNext(newNext: currNext)
        currNext!.setPrevious(newPrev: currPrev)
        
        if (node === dealer) {
            dealer = currNext!
        }
        
        self.size -= 1
    }
    
    //Will loop forever if not used correctly.
    //fileprivate so only Iterator can safely remove an element
    fileprivate func remove(element: Element) {
        var current = dealer
        while (current.getValue() !== element) {
            current = current.getNext()!
        }
        
        self.remove(node: current)
    }
    
    func getSize() -> Int {
        return self.size
    }
    
//    func incrementDealer() {
//        dealer = origDealer.getNext()!
//        origDealer = dealer
//    }
}

class Node<Element: AnyObject> {
    private var next: Node<Element>?
    private var previous: Node<Element>?
    private var value: Element
    
    fileprivate init(value: Element) {
        self.value = value
        self.next = nil
        self.previous = nil
    }
    
    func getNext() -> Node<Element>? {
        return next
    }
    
    func getPrevious() -> Node<Element>? {
        return previous
    }
    
    func getValue() -> Element {
        return value
    }
    
    fileprivate func setNext(newNext: Node<Element>?) {
        next = newNext
    }
    
    fileprivate func setPrevious(newPrev: Node<Element>?) {
        previous = newPrev
    }
    
    fileprivate func setValue(newVal: Element) {
        value = newVal
    }
}
