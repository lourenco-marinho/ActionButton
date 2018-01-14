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

public typealias ActionButtonItemAction = (ActionButtonItem) -> Void

open class ActionButtonItem: NSObject {
    
    /// The action the item should perform when tapped
    open var action: ActionButtonItemAction?
    
    /// Description of the item's action. This should not be changed if the text length changes as it does not trigger a resize of the item view
    open var text: String {
        get {
            return self.label.text!
        }
        
        set {
            self.label.text = newValue
        }
    }
    /// The color of the item text
    open var textColor: UIColor {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    /// View that will hold the item's button and label
    internal var view: UIView!
    
    /// Label that contain the item's *text*
    fileprivate var label: UILabel!
    
    /// Main button that will perform the defined action
    fileprivate var button: UIButton!
    
    /// Image used by the button
    fileprivate var image: UIImage!
    
    /// Size needed for the *view* property presente the item's content
    fileprivate(set) public var viewSize = CGSize(width: 200, height: 35)
    
    /// Button's size by default the button is 35x35
    fileprivate(set) public var buttonSize = CGSize(width: 35, height: 35)
    
    fileprivate var labelBackground: UIView!
    /// The inset
    let backgroundInset = CGSize(width: 10, height: 10)
    
    /**
        :param: title Title that will be presented when the item is active
        :param: image Item's image used by the it's button
    */
    public init(title optionalTitle: String?, image: UIImage?, buttonSize: CGSize = CGSize(width: 35, height: 35), viewSize: CGSize = CGSize(width: 200, height: 35), textFont: UIFont = UIFont.systemFont(ofSize: 14)) {
        super.init()
        self.buttonSize = buttonSize
        self.viewSize = viewSize
        self.viewSize.height = buttonSize.height
        self.view = UIView(frame: CGRect(origin: CGPoint.zero, size: self.viewSize))
        self.view.alpha = 0
        self.view.isUserInteractionEnabled = true
        self.view.backgroundColor = UIColor.clear
        
        self.button = UIButton(type: .custom)
        self.button.frame = CGRect(origin: CGPoint(x: self.viewSize.width - self.buttonSize.width, y: 0), size: buttonSize)
        self.button.layer.shadowOpacity = 1
        self.button.layer.shadowRadius = 2
        self.button.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.button.layer.shadowColor = UIColor.gray.cgColor
        self.button.addTarget(self, action: #selector(ActionButtonItem.buttonPressed(_:)), for: .touchUpInside)

        if let unwrappedImage = image {
            self.button.setImage(unwrappedImage, for: UIControlState())
        }
                
        if let text = optionalTitle , text.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == false {
            self.label = UILabel()
            self.label.font = textFont
            self.label.textColor = UIColor.darkGray
            self.label.textAlignment = .right
            self.label.text = text
            self.label.numberOfLines = 0
            self.label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ActionButtonItem.labelTapped(_:))))
            self.label.sizeToFit()
            
            self.labelBackground = UIView()
            self.labelBackground.frame = self.label.frame
            self.labelBackground.backgroundColor = UIColor.white
            self.labelBackground.layer.cornerRadius = 3
            self.labelBackground.layer.shadowOpacity = 0.8
            self.labelBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
            self.labelBackground.layer.shadowRadius = 0.2
            self.labelBackground.layer.shadowColor = UIColor.lightGray.cgColor
            
            // Adjust the label's background inset
            self.labelBackground.frame.size.width = self.label.frame.size.width + backgroundInset.width
            self.labelBackground.frame.size.height = self.label.frame.size.height + backgroundInset.height
            self.label.frame.origin.x = self.label.frame.origin.x + backgroundInset.width / 2
            self.label.frame.origin.y = self.label.frame.origin.y + backgroundInset.height / 2
            
            // Adjust label's background position
            self.labelBackground.frame.origin.x = CGFloat(130 - self.label.frame.size.width)
            self.labelBackground.center.y = self.view.center.y
            self.labelBackground.addSubview(self.label)
            
            // Add Tap Gestures Recognizer
            let tap = UITapGestureRecognizer(target: self, action: #selector(ActionButtonItem.labelTapped(_:)))
            self.view.addGestureRecognizer(tap)
            
            self.view.addSubview(self.labelBackground)
        }
        
        self.view.addSubview(self.button)
    }
        
    //MARK: - Button Action Methods
    @objc func buttonPressed(_ sender: UIButton) {
        if let unwrappedAction = self.action {
            unwrappedAction(self)
        }
    }
    
    //MARK: - Gesture Recognizer Methods
    @objc func labelTapped(_ gesture: UIGestureRecognizer) {
        if let unwrappedAction = self.action {
            unwrappedAction(self)
        }
    }
}
