//
//  ViewController.swift
//  FreeTexasHoldEm
//
//  Created by Steven Rothstein on 10/29/18.
//  Copyright © 2018 Steven Rothstein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var chipViews: [UIImageView]!
    
    var minX: CGFloat = 0
    var maxX: CGFloat = 0
    var minY: CGFloat = 0
    var maxY: CGFloat = 0
    
    var stopRecursion = false
    
    //TODO: will not work on ipads until autolayout is put in. miny/maxy calculations won't work
    
    func getRandomEdgeCoordinates() -> (x: CGFloat, y: CGFloat) {
        let randomX = Float.random(in: Float(minX)...Float(maxX))
        let randomY = Float.random(in: Float(minY)...Float(maxY))
        
        let topEdge = (CGFloat(randomX) , minY)
        let leftEdge = (minX , CGFloat(randomY))
        let rightEdge = (maxX , CGFloat(randomY))
        let bottomEdge = (CGFloat(randomX) , maxY)
        
        let edges = [topEdge, leftEdge, rightEdge, bottomEdge]
        
        return edges[Int.random(in: 0..<edges.count)]
    }
    
    func recursiveAnim() {
        if (stopRecursion) {
            return
        }
        
        var myDelay = 0.0
        
        let delayInc = 0.2
        
        for x in stride(from: chipViews.count - 1, through: 0, by: -1) {
            
            let (newX, newY) = self.getRandomEdgeCoordinates()
            
            UIView.animate(withDuration: 2, delay: 0.0, options: [.curveLinear], animations: {
                self.chipViews[x].center.x = CGFloat(newX)
                self.chipViews[x].center.y = CGFloat(newY)
            }, completion: {
                (value: Bool) in
                if (x == 0) {
                    self.recursiveAnim()
                }
            })
            myDelay += delayInc
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stopRecursion = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.recursiveAnim()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chipViews = chipViews.sorted(by: { $0.tag < $1.tag})
        
        let firstChip = chipViews[0]
        
        let screenMaxX = UIScreen.main.bounds.maxX
        let screenMaxY = UIScreen.main.bounds.maxY
        
        let dx = firstChip.center.x
        let dy = screenMaxY - firstChip.center.y
        
        minX = dx
        maxX = screenMaxX - dx
        
        minY = dy
        maxY = screenMaxY - dy
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopRecursion = true        
    }
}

