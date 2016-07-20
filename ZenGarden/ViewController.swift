//
//  ViewController.swift
//  ZenGarden
//
//  Created by Flatiron School on 6/30/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var rakeOutlet: UIImageView!
    @IBOutlet weak var swordOutlet: UIImageView!
    @IBOutlet weak var rockOutlet: UIImageView!
    @IBOutlet weak var shrubOutlet: UIImageView!
    
    var objects: [UIImageView] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.objects = [swordOutlet, rockOutlet, shrubOutlet, rakeOutlet]
        initialObjectSetup(maxPartOfTheScreen: 0.25)
        randomizeObjects(animationDuration: 0.5)
    }
    
    
    func moveObject(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translationInView(self.view)
        
        if let object = recognizer.view {
            object.center = CGPoint(x:object.center.x + translation.x, y:object.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        if recognizer.state == .Ended {
            if let object = recognizer.view {
                clearObject(object as! UIImageView)
                if win() {
                    winAlert()
                }
            }
        }
    }
    
    
    func clearObject(object: UIImageView) {
        let superFrame = self.view.frame
        let objectFrame = object.frame
        let offsetX = object.frame.width / 2
        let offsetY = object.frame.height / 2
        
        if superFrame.maxX < objectFrame.maxX ||
            superFrame.maxY < objectFrame.maxY ||
            superFrame.minX > objectFrame.minX ||
            superFrame.minY > objectFrame.minY {
            
            UIView.animateWithDuration(0.1) {
                if superFrame.maxX < objectFrame.maxX { object.center.x = superFrame.maxX - offsetX }
                if superFrame.maxY < objectFrame.maxY { object.center.y = superFrame.maxY - offsetY }
                if superFrame.minX > objectFrame.minX { object.center.x = superFrame.minX + offsetX }
                if superFrame.minY > objectFrame.minY { object.center.y = superFrame.minY + offsetY }
                self.view.layoutIfNeeded()
                
            }
        }
    }
    
    
    func win() -> Bool {
        if swordWin() && shrubAndRakeWin() && rockWin() {
            return true
        }
        return false
    }
    
    func swordWin() -> Bool {
        let swordMaxTotal = self.swordOutlet.frame.maxX + self.swordOutlet.frame.maxY
        let swordMinTotal = self.swordOutlet.frame.minX + self.swordOutlet.frame.minY
        let screenTotal = self.view.frame.maxX + self.view.frame.maxY
        
        if screenTotal < swordMaxTotal + 20 || swordMinTotal < 20 {
            return true
        }
        
        return false
    }
    
    func shrubAndRakeWin() -> Bool {
        let shrubCenter = self.shrubOutlet.center
        let rakeCenter = self.rakeOutlet.center
        
        if abs(shrubCenter.x - rakeCenter.x) < 40 && abs(shrubCenter.y - rakeCenter.y) < 40 {
            return true
        }
        
        return false
    }
    
    func rockWin() -> Bool {
        let swordCenterY = self.swordOutlet.center.y
        let rockMinY = self.rockOutlet.frame.minY
        let rockMaxY = self.rockOutlet.frame.maxY
        let superCenterY = self.view.center.y
        
        if (swordCenterY > superCenterY && rockMaxY < superCenterY) ||
            (swordCenterY < superCenterY && rockMinY > superCenterY) {
            return true
        }

        return false
    }
    
    
    func winAlert() {
        let alertController = UIAlertController(title: "You won",
                                                message: "Good job! Your garden looks marvelous!",
                                                preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Sweet", style: UIAlertActionStyle.Default, handler: {
            UIAlertController in
            self.randomizeObjects(animationDuration: 0.5) }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    func initialObjectSetup(maxPartOfTheScreen maxPartOfTheScreen: CGFloat) {
        
        self.view.removeConstraints(self.view.constraints)
        
        for object in self.objects {
            let originalWidth = object.image?.size.width
            let originalHeight = object.image?.size.height
            var newSize: (CGFloat, CGFloat) = (x:0, y:0)
            
            if let width = originalWidth, let height = originalHeight {
                newSize = calculateNewSize(width: width, height: height, maxPartOfTheScreen: maxPartOfTheScreen)
            } else {
                object.removeFromSuperview()
            }
            
            object.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
            object.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true
            object.widthAnchor.constraintEqualToConstant(newSize.0).active = true
            object.heightAnchor.constraintEqualToConstant(newSize.1).active = true
            
            let dragRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.moveObject(_:)))
            object.addGestureRecognizer(dragRecognizer)
        }
        
    }
    
    
    func randomizeObjects(animationDuration animationDuration: Double) {
        
        for object in objects {
            
            let maxOffsetX = self.view.bounds.width - object.frame.size.width
            let maxOffsetY = self.view.bounds.height - object.frame.size.height
            
            let randomOffsetX = CGFloat(arc4random_uniform(UInt32(maxOffsetX)))
            let randomOffsetY = CGFloat(arc4random_uniform(UInt32(maxOffsetY)))
            
            UIView.animateWithDuration(animationDuration) {
                object.removeFromSuperview()
                self.view.addSubview(object)
                
                object.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor, constant: randomOffsetX).active = true
                object.topAnchor.constraintEqualToAnchor(self.view.topAnchor, constant: randomOffsetY).active = true
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    
    func calculateNewSize(width width:CGFloat, height: CGFloat, maxPartOfTheScreen: CGFloat) -> (CGFloat, CGFloat) {
        
        let widthProportion = width / self.view.bounds.width
        let heightProportion = height / self.view.bounds.height
        
        let widthResizeCoefficient = widthProportion / maxPartOfTheScreen
        let heightResizeCoefficient = heightProportion / maxPartOfTheScreen
        let resizeCoefficient = max(widthResizeCoefficient, heightResizeCoefficient)
        
        
        let newWidth = width / resizeCoefficient
        let newHeight = height / resizeCoefficient
        
        return (newWidth, newHeight)
        
    }
    
    
}

