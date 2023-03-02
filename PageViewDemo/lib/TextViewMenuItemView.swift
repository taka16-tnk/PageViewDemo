//
//  TextViewMenuItemView.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/02/23.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit

class TextViewMenuItemView: TabPageViewControllerMenuItemView {
    
    var title: String? {
        get {
            return self.titleLabel.text
        }
        set(string) {
            self.titleLabel.text = string
            self.titleLabel.sizeToFit()
        }
    }
    
    var selectedTitleColor: UIColor? {
        get {
            return self.titleLabel.highlightedTextColor
        }
        set (color) {
            self.titleLabel.highlightedTextColor = color
        }
    }
    
    var normalTitleColor: UIColor? {
        get {
            return self.titleLabel.textColor
        }
        set(color) {
            self.titleLabel.textColor = color
        }
    }
    
    private var titleLabel: UILabel!
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override func commonInit() {
        super.commonInit()
        
        self.titleLabel = UILabel()
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.textColor = .lightGray
        self.titleLabel.highlightedTextColor = .black
        self.addSubview(self.titleLabel)
        self.titleLabel.centerXAnchor
            .constraint(equalTo: self.centerXAnchor)
            .isActive = true
        self.titleLabel.centerYAnchor
            .constraint(equalTo: self.centerYAnchor)
            .isActive = true
    }
    
    override func didSelect() {
        self.titleLabel.isHighlighted = true
    }
    
    override func didDeselect() {
        self.titleLabel.isHighlighted = false
    }
}
