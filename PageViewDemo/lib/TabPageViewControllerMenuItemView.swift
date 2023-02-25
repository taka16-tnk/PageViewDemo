//
//  TabPageViewControllerMenuItemView.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/02/23.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//


import UIKit

// このクラスを直接使わず継承したクラスを使う
class TabPageViewControllerMenuItemView: UIView, TabPageViewControllerMenuItemViewDelegate {
    
    var parent: TabPageViewController!
    var tapRecognizer: UITapGestureRecognizer!
    
    func didSelect() {}
    func didDeselect() {}
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        // タップ用のインスタンスを生成する
        self.tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(TabPageViewControllerMenuItemView.tellTapEventToParent)
        )
        self.addGestureRecognizer(self.tapRecognizer)
    }
    
    @objc func tellTapEventToParent() {
        parent.menuDidSelectByTap(index: self.tag)
    }
    
}
