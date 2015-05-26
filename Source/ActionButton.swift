// ActionButton.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 ActionButton
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

typealias ActionButtonAction = (ActionButton) -> Void

public class ActionButton: NSObject {
    
    var active: Bool = false
    var action: ActionButtonAction?
    var items: [ActionButtonItem]?
    var backgroundColor: UIColor? {
        willSet {
            floatButton.backgroundColor = newValue
        }
    }
    
    private var floatButton: UIButton!
    private var contentView: UIView!
    private var parentView: UIView!
    private var blurVisualEffect: UIVisualEffectView!
    private let itemOffset = -55
    private let floatButtonRadius = 50
    
    public init(attachedToView view: UIView, items: [ActionButtonItem]?) {
        super.init()
        
        self.parentView = view
        self.items = items
        let bounds = self.parentView.bounds
        
        self.floatButton = UIButton.buttonWithType(.Custom) as! UIButton
        self.floatButton.layer.cornerRadius = CGFloat(floatButtonRadius / 2)
        self.floatButton.layer.shadowOpacity = 1
        self.floatButton.layer.shadowRadius = 2
        self.floatButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.floatButton.layer.shadowColor = UIColor.grayColor().CGColor
        self.floatButton.setTitle("+", forState: .Normal)
        self.floatButton.backgroundColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0)
        self.floatButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        self.floatButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 35)
        self.floatButton.userInteractionEnabled = true
        self.floatButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.floatButton.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
        self.floatButton.addTarget(self, action: Selector("buttonTouchDown:"), forControlEvents: .TouchDown)
        self.parentView.addSubview(self.floatButton)

        self.contentView = UIView(frame: bounds)
        self.blurVisualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        self.blurVisualEffect.frame = self.contentView.frame
        self.contentView.addSubview(self.blurVisualEffect)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("backgroundTapped:"))
        self.contentView.addGestureRecognizer(tap)
        
        self.installConstraints()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Auto Layout Methods
    
    private func installConstraints() {
        let views = ["floatButton":self.floatButton, "parentView":self.parentView]
        let width = NSLayoutConstraint.constraintsWithVisualFormat("H:[floatButton(\(floatButtonRadius))]", options: nil, metrics: nil, views: views)
        let height = NSLayoutConstraint.constraintsWithVisualFormat("V:[floatButton(\(floatButtonRadius))]", options: nil, metrics: nil, views: views)
        self.floatButton.addConstraints(width)
        self.floatButton.addConstraints(height)
        
        let trailingSpacing = NSLayoutConstraint.constraintsWithVisualFormat("V:[floatButton]-15-|", options: nil, metrics: nil, views: views)
        let bottomSpacing = NSLayoutConstraint.constraintsWithVisualFormat("H:[floatButton]-15-|", options: nil, metrics: nil, views: views)
        self.parentView.addConstraints(trailingSpacing)
        self.parentView.addConstraints(bottomSpacing)
    }
    
    // MARK: - Button Actions Methods
    
    func buttonTapped(sender: UIControl) {
        animatePressingWithScale(1.0)
        
        if let unwrappedAction = self.action {
            unwrappedAction(self)
        }
    }
    
    func buttonTouchDown(sender: UIButton) {
        animatePressingWithScale(0.9)
    }
    
    // MARK: - Gesture Recognizer Methods
    
    func backgroundTapped(gesture: UIGestureRecognizer) {
        if self.active {
            self.toggle()
        }
    }
    
    // MARK: - Custom Methods
    func toggleMenu() {
        self.placeButtonItems()
        self.toggle()
    }
    
    // MARK: - Float Button Items Placement
    
    private func placeButtonItems() {
        if let optionalItems = self.items {
            for item in optionalItems {
                item.view.center = CGPoint(x: self.floatButton.center.x - 83, y: self.floatButton.center.y)
                item.view.removeFromSuperview()
                
                self.contentView.addSubview(item.view)
            }
        }
    }
    
    // MARK - Float Menu Methods
    
    private func toggle() {
        self.animateMenu()
        self.showBlur()
        
        self.active = !self.active
    }
    
    private func animateMenu() {
        let rotation = self.active ? 0 : CGFloat(M_PI_4)
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: nil, animations: {
            self.floatButton.transform = CGAffineTransformMakeRotation(rotation)
    
            if self.active == false {
                self.contentView.alpha = 1.0
                
                if let optionalItems = self.items {
                    for (index, item) in enumerate(optionalItems) {
                        let offset = index + 1
                        let translation = self.itemOffset * offset
                        item.view.transform = CGAffineTransformMakeTranslation(0, CGFloat(translation))
                        item.view.alpha = 1
                    }
                }
            } else {
                self.contentView.alpha = 0.0
                
                if let optionalItems = self.items {
                    for item in optionalItems {
                        item.view.transform = CGAffineTransformMakeTranslation(0, 0)
                        item.view.alpha = 0
                    }
                }
            }
        }, completion: {completed in
            if self.active == false {
                self.hideBlur()
            }
        })
    }
    
    private func animateClick() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: .Repeat | .Autoreverse, animations: {
            self.floatButton.transform = CGAffineTransformMakeScale(1.2, 1.2)
        }, completion: nil)
    }
    
    private func showBlur() {
        self.parentView.insertSubview(self.contentView, belowSubview: self.floatButton)
    }
    
    private func hideBlur() {
        self.contentView.removeFromSuperview()
    }
    
    private func animatePressingWithScale(scale: CGFloat) {
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: nil, animations: {
            self.floatButton.transform = CGAffineTransformMakeScale(scale, scale)
        }, completion: nil)
    }
}
