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

public typealias ActionButtonAction = (ActionButton) -> Void

open class ActionButton: NSObject {
    
    /// The action the button should perform when tapped
    open var action: ActionButtonAction?

    /// The button's background color : set default color and selected color
    open var backgroundColor: UIColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0) {
        willSet {
            floatButton.backgroundColor = newValue
            backgroundColorSelected = newValue
        }
    }
    
    /// The button's background color : set default color
    open var backgroundColorSelected: UIColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0)
    
    /// Indicates if the buttons is active (showing its items)
    fileprivate(set) open var active: Bool = false
    
    /// An array of items that the button will present
    internal var items: [ActionButtonItem]? {
        willSet {
            for abi in self.items! {
                abi.view.removeFromSuperview()
            }
        }
        didSet {
            placeButtonItems()
            showActive(true)
        }
    }
    /// The blur effect style of the background when menu opens. Set it to nil to disable blur
    public var backgroundBlurStyle: UIBlurEffectStyle? = .extraLight
    var image: UIImage?
    
    /// The button that will be presented to the user
    fileprivate var floatButton: UIButton!
    
    /// View that will hold the placement of the button's actions
    fileprivate var contentView: UIView!
    
    /// View where the *floatButton* will be displayed
    fileprivate var parentView: UIView!
    
    /// Blur effect that will be presented when the button is active
    fileprivate var blurVisualEffect: UIVisualEffectView!
    
    /// Distance between each item action
    public var itemSpacing: CGFloat = 20
    
    /// The button offset from the bottom
    fileprivate(set) public var buttonOffset: CGPoint = CGPoint(x: 15, y: 15)
    /// the float button's size
    fileprivate(set) public var floatButtonDiameter: CGFloat = 50
    
    public init(attachedToView view: UIView, items: [ActionButtonItem]?, buttonSize: CGFloat = 50, buttonOffset: CGPoint = CGPoint(x: 15, y: 15)) {
        super.init()
        self.buttonOffset = buttonOffset
        self.floatButtonDiameter = buttonSize
        self.parentView = view
        self.items = items
        let bounds = self.parentView.bounds
        
        self.floatButton = UIButton(type: .custom)
        self.floatButton.layer.cornerRadius = CGFloat(floatButtonDiameter / 2)
        self.floatButton.layer.shadowOpacity = 1
        self.floatButton.layer.shadowRadius = 2
        self.floatButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.floatButton.layer.shadowColor = UIColor.gray.cgColor
        self.floatButton.setTitle("+", for: UIControlState())
        self.floatButton.setImage(nil, for: UIControlState())
        self.floatButton.backgroundColor = self.backgroundColor
        self.floatButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 35)
        self.floatButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        self.floatButton.isUserInteractionEnabled = true
        self.floatButton.translatesAutoresizingMaskIntoConstraints = false
        
        floatButton.addTarget(self, action: #selector(dragEnter(_:)), for: .touchDragEnter)
        floatButton.addTarget(self, action: #selector(dragExit(_:)), for: .touchDragExit)
        floatButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        self.floatButton.addTarget(self, action: #selector(ActionButton.buttonTapped(_:)), for: .touchUpInside)
        self.floatButton.addTarget(self, action: #selector(ActionButton.buttonTouchDown(_:)), for: .touchDown)
        self.parentView.addSubview(self.floatButton)

        self.contentView = UIView(frame: bounds)
        self.blurVisualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        self.blurVisualEffect.frame = self.contentView.frame
        self.blurVisualEffect.effect = nil
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.blurVisualEffect)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ActionButton.backgroundTapped(_:)))
        self.contentView.addGestureRecognizer(tap)
        
        self.installConstraints()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set Methods
    open func setTitle(_ title: String?, forState state: UIControlState) {
        floatButton.setImage(nil, for: state)
        floatButton.setTitle(title, for: state)
        floatButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
    
    open func setImage(_ image: UIImage?, forState state: UIControlState) {
        setTitle(nil, forState: state)
        floatButton.setImage(image, for: state)
        floatButton.adjustsImageWhenHighlighted = false
        floatButton.contentEdgeInsets = UIEdgeInsets.zero
    }
    
    //MARK: - Auto Layout Methods
    /**
        Install all the necessary constraints for the button. By the default the button will be placed at 15pts from the bottom and the 15pts from the right of its *parentView*
    */
    fileprivate func installConstraints() {
        let views: [String: UIView] = ["floatButton":self.floatButton, "parentView":self.parentView]
        let width = NSLayoutConstraint.constraints(withVisualFormat: "H:[floatButton(\(floatButtonDiameter))]", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        let height = NSLayoutConstraint.constraints(withVisualFormat: "V:[floatButton(\(floatButtonDiameter))]", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        self.floatButton.addConstraints(width)
        self.floatButton.addConstraints(height)
        
        let trailingSpacing = NSLayoutConstraint.constraints(withVisualFormat: "V:[floatButton]-\(buttonOffset.y)-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        let bottomSpacing = NSLayoutConstraint.constraints(withVisualFormat: "H:[floatButton]-\(buttonOffset.x)-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        self.parentView.addConstraints(trailingSpacing)
        self.parentView.addConstraints(bottomSpacing)
    }
    
    //MARK: - Button Actions Methods
    @objc func buttonTapped(_ sender: UIControl) {
        animatePressingWithScale(1.0)
        
        if let unwrappedAction = self.action {
            unwrappedAction(self)
        }
    }
    @objc private func dragEnter(_ sender: Any) {
        animatePressingWithScale(0.9)
    }
    @objc private func dragExit(_ sender: Any) {
        animatePressingWithScale(1.0)
    }
    @objc private func touchUpOutside(_ sender: UIControl) {
        animatePressingWithScale(1.0)
    }
    
    @objc func buttonTouchDown(_ sender: UIButton) {
        animatePressingWithScale(0.9)
    }
    
    //MARK: - Gesture Recognizer Methods
    @objc func backgroundTapped(_ gesture: UIGestureRecognizer) {
        if self.active {
            self.toggle()
        }
    }
    
    //MARK: - Custom Methods
    /**
        Presents or hides all the ActionButton's actions
    */
    open func toggleMenu() {
        self.placeButtonItems()
        self.toggle()
    }
    
    //MARK: - Action Button Items Placement
    /**
        Defines the position of all the ActionButton's actions
    */
    fileprivate func placeButtonItems() {
        if let optionalItems = self.items {
            for item in optionalItems {
                item.view.center = CGPoint(x: self.floatButton.center.x - (item.viewSize.width/2 - item.buttonSize.width/2), y: self.floatButton.center.y)
                item.view.removeFromSuperview()
                
                self.contentView.addSubview(item.view)
            }
        }
    }
    
    //MARK - Float Menu Methods
    /**
        Presents or hides all the ActionButton's actions and changes the *active* state
    */
    fileprivate func toggle() {
        self.animateMenu()
        self.showBlur()
        
        self.active = !self.active
        self.floatButton.backgroundColor = self.active ? backgroundColorSelected : backgroundColor
        self.floatButton.isSelected = self.active
    }
    
    fileprivate func animateMenu() {
        let rotation = self.active ? 0 : CGFloat(Double.pi/4)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            
            if self.floatButton.imageView?.image == nil {
                self.floatButton.transform = CGAffineTransform(rotationAngle: rotation)
            }
    
            self.showActive(false)
        }, completion: {completed in
            if self.active == false {
                self.hideBlur()
            }
        })
    }
    
    fileprivate func showActive(_ active: Bool) {
        if self.active == active {
//            self.contentView.alpha = 1.0
            if let style = self.backgroundBlurStyle {
                self.blurVisualEffect.effect = UIBlurEffect(style: style)
            }
            if let optionalItems = self.items {
                for (index, item) in optionalItems.enumerated() {
                    let offset = index + 1
                    let translation = -1 * (itemSpacing + item.buttonSize.height) * CGFloat(offset)
                    item.view.transform = CGAffineTransform(translationX: 0, y: translation)
                    item.view.alpha = 1
                }
            }
        } else {
//            self.contentView.alpha = 0.0
            self.blurVisualEffect.effect = nil
            if let optionalItems = self.items {
                for item in optionalItems {
                    item.view.transform = CGAffineTransform(translationX: 0, y: 0)
                    item.view.alpha = 0
                }
            }
        }
    }
    
    fileprivate func showBlur() {
        self.parentView.insertSubview(self.contentView, belowSubview: self.floatButton)
    }
    
    fileprivate func hideBlur() {
        self.contentView.removeFromSuperview()
    }
    
    /**
        Animates the button pressing, by the default this method just scales the button down when it's pressed and returns to its normal size when the button is no longer pressed
    
        - parameter scale: how much the button should be scaled
    */
    fileprivate func animatePressingWithScale(_ scale: CGFloat) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            self.floatButton.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
}
