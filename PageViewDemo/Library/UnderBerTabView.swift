//
//  UnderBerTabView.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/02/25.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit

final class UnderBerTabView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var barView: UIView!
    
    fileprivate var selectedIndex = 0
    
    private var config = UnderBarTabViewConfig()
    private var texts: [String] = []
}
