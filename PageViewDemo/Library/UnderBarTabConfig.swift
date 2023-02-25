//
//  UnderBarTabConfig.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/02/25.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit

// ビュー全体の設定
struct UnderBarTabViewConfig {
    /// .fixed(width:) ⇒ すべてのタブは固定幅、.flexible(margin:) ⇒ 文字列の幅に応じてタブの幅も可変
    let type: CGFloat
    /// ビュー全体の余白
    let insets: UIEdgeInsets
    /// タブ間の余白
    let itemSpacing: CGFloat
    /// 選択状態とは別にタブの文字色を変えたい場合に使用
    let emphasisIndex: Int?
    /// 下線の色
    let underBarColor: UIColor
    /// 各タブの設定
    let cellConfig: UnderBarTabCellConfig
    
    init(type: CGFloat = UIScreen.main.bounds.width / 2,
         insets: UIEdgeInsets = .zero,
         itemSpacing: CGFloat = .zero,
         emphasisIndex: Int? = nil,
         underBarColor: UIColor = .blue,
         cellConfig: UnderBarTabCellConfig = UnderBarTabCellConfig()) {
        self.type = type
        self.insets = insets
        self.itemSpacing = itemSpacing
        self.emphasisIndex = emphasisIndex
        self.underBarColor = underBarColor
        self.cellConfig = cellConfig
    }
}


// 各タブの設定
struct UnderBarTabCellConfig {
    /// 非選択時の文字色
    let normalTextColor: UIColor
    /// 選択時の文字色
    let selectedTextColor: UIColor
    /// 強調するタブの文字色
    let emphasisTextColor: UIColor
    ///　非選択時のフォント
    let normalTextFont: UIFont
    /// 選択時のフォント
    let selectedTextFont: UIFont
    
    init(normalTextColor: UIColor = .lightGray,
         selectedTextColor: UIColor = .red,
         emphasisTextColor: UIColor = .black,
         normalTextFont: UIFont = UIFont(name: "HiraginoSans-W3", size: 12.0)!,
         selectedTextFont: UIFont = UIFont(name: "HiraginoSans-W6", size: 13.0)!) {
        self.normalTextColor = normalTextColor
        self.selectedTextColor = selectedTextColor
        self.emphasisTextColor = emphasisTextColor
        self.normalTextFont = normalTextFont
        self.selectedTextFont = selectedTextFont
    }
}
