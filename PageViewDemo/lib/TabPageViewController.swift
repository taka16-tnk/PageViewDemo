//
//  TabPageViewController.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/02/23.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit

// プロトコルとは、具体的な処理内容は書かず、クラスや構造体が実装するプロパティとメソッドを定義する機能です
protocol TabPageViewControllerMenuItemViewDelegate {
    var parent: TabPageViewController! { set get }
    func didSelect()    // メインアプリが設定ペインのメインビューを表示したことを設定ペインに通知する
    func didDeselect()  // ピン留めの一つが選択消去された時に呼ばれる?
}

class TabPageViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    struct PageInfo {
        var menuItemView: TabPageViewControllerMenuItemView
        var vc: UIViewController
    }
    
    // レイアウトパーツとの紐付け
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var contentView: UIView!
    
    
    // pageView上で表示するViewControllerを管理する配列
    var pageInfoList: [PageInfo] = []
    var currentPageIndex = 0
    var menuItemViewWidth: CGFloat?
    var menuBackgroundDesignView: UIView?
    var shourldIgnoreScrollDelegate = false
    
    private var pageViewController: UIPageViewController!
    private var menuScrollOffsetXList: [CGFloat] = []

    override func viewDidLoad() {
        super.viewDidLoad()

       
        
        if let designView = self.menuBackgroundDesignView {
            // addView 画面遷移ではなく、Viewを重ねるイメージ
            self.menuBackground.addSubview(designView)
        }
        
        // ページビューコントローラ準備
        self.setupPageViewController()
        
        // ページ準備
        self.setupPageList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        self.menuBackground.frame.size.width = self.view.frame.width / CGFloat(self.pageInfoList.count)
        if let designView = self.menuBackgroundDesignView {
            designView.center = self.menuBackground.center
        }
    }

    
    // ページビューコントローラ諸々
    private func setupPageViewController() {
        
        // 生成
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        // 親にセット
        self.pageViewController.view.frame.size = self.contentView.frame.size
        self.addChild(self.pageViewController)
        self.contentView.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParent: self)
        
        // デリゲート
        self.pageViewController.delegate   = self
        self.pageViewController.dataSource = self
        
        // ジェスチャー
        self.contentView.gestureRecognizers = self.pageViewController.gestureRecognizers
        
    }
    
    // ページ諸々
    func setupPageList() {
        
        // メニュー作る
        var constraintsString = "|"
        var menuItemViewList: [String: UIView] = [:]
        for i in 0..<self.pageInfoList.count {
            
            let menuItemView = self.pageInfoList[i].menuItemView
            menuItemView.translatesAutoresizingMaskIntoConstraints = false
            self.menuView.addSubview(menuItemView)
            
            // 高さ制約
            self.menuView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat : "V:|[view]|",
                options          : [],
                metrics          : nil,
                views            : ["view": menuItemView]
            ))
            
            // 幅制約
            menuItemViewList["view\(i)"] = menuItemView
            constraintsString += "[view\(i)]"
            self.menuView.addConstraint(NSLayoutConstraint(
                item       : menuItemView,
                attribute  : .width,
                relatedBy  : .equal,
                toItem     : self.menuView,
                attribute  : .width,
                multiplier : 1.0 / CGFloat(self.pageInfoList.count),
                constant   : 0
            ))
            
            // タグのセット
            self.pageInfoList[i].vc.view.tag = i + 1
            self.pageInfoList[i].menuItemView.tag = i + 1
        }
        
        // 中身があれば
        if self.pageInfoList.count > 0 {
            
            // 幅制約続き
            constraintsString += "|"
            self.menuView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat : constraintsString,
                options          : [],
                metrics          : nil,
                views            : menuItemViewList
            ))
            
            // 最初のページをセット
            self.pageViewController.setViewControllers([self.pageInfoList[self.currentPageIndex].vc], direction: .forward, animated: false, completion: nil)
            self.pageInfoList[self.currentPageIndex].menuItemView.didSelect()
        }
    }
    
    // 左隣のページ取得
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag - 1
        
        index -= 1
        if index < 0 {
            index = self.pageInfoList.count - 1
        }
        return self.pageInfoList[index].vc
    }
    
    // 右隣のページ取得
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag - 1
        
        index += 1
        if index > self.pageInfoList.count - 1 {
            index = 0
        }
        return self.pageInfoList[index].vc
    }
    
    // ページ数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageInfoList.count
    }
    
    // 遷移アニメーションが完了した時
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // 前のメニューを非選択状態に
            self.pageInfoList[self.currentPageIndex].menuItemView.didDeselect()
            // インデックス更新
            self.currentPageIndex = self.pageViewController.viewControllers!.last!.view.tag - 1
            // 新しいメニューを選択状態に
            self.pageInfoList[self.currentPageIndex].menuItemView.didSelect()

            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.menuBackground.frame.origin.x = self.pageInfoList[self.currentPageIndex].menuItemView.frame.origin.x
            })
        }
    }

    //  メニューがタップされたときの処理
    func menuDidSelectByTap(index: Int) {
        guard index - 1 != self.currentPageIndex else {
            return
        }
        // 前のメニューを非選択状態に
        self.pageInfoList[self.currentPageIndex].menuItemView.didDeselect()
        // インデックス更新
        let direction: UIPageViewController.NavigationDirection = index - 1 > self.currentPageIndex ? .forward : .reverse
        self.currentPageIndex = index - 1
        // 画面入れ替え
        self.pageViewController.setViewControllers(
            [self.pageInfoList[self.currentPageIndex].vc],
            direction  : direction,
            animated   : true,
            completion : nil
        )
        // 新しいメニューを選択状態に
        self.pageInfoList[self.currentPageIndex].menuItemView.didSelect()

        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.menuBackground.frame.origin.x = self.pageInfoList[self.currentPageIndex].menuItemView.frame.origin.x
        })
    }

}
