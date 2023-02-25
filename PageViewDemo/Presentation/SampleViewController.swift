//
//  SampleViewController.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/02/25.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit

final class SampleViewController: UIViewController {

    @IBOutlet weak var tabView: UnderBerTabView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTabView()
    }
}

extension SampleViewController {
    
    private func setupTabView() {
        self.setupNoLoopTabView()
    }
    
    private func setupNoLoopTabView() {
        let cellConfig = UnderBarTabCellConfig(
            normalTextColor: .gray,
            selectedTextColor: .blue,
            emphasisTextColor: .cyan
        )
        let config = UnderBarTabViewConfig(
            emphasisIndex: 2,
            cellConfig: cellConfig
        )
//        self.tabView.setup(config: config)
//        self.tabView.setData(["1", "2", "3", "4", "5"])
    }
}
