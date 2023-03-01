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
        
        // ナビゲーションバーの背景色
        self.navigationController?.navigationBar.barTintColor = .red
        // ナビゲーションバーのアイテムの色
        self.navigationController?.navigationBar.tintColor = .white
        
        // ページ情報
        self.initPageInfo()
               
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
    
    func initPageInfo() {
        pageInfoList = [
            {
                let view = TextViewMenuItemView()
                let vc   = LoginContentViewController()
                let body = UILabel()
                view.title = "ログイン"
                view.parent = self
//                body.text = "ログイン画面を実装する"
                body.sizeToFit()
                body.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
                body.center = vc.view.center
                vc.view.addSubview(body)
                return TabPageViewController.PageInfo(menuItemView: view, vc: vc)
            }(),
            {
                let view = TextViewMenuItemView()
                let vc   = RegisterContentViewController()
                let body = UILabel()
                view.title = "新規登録"
                view.parent = self
//                body.text = "新規登録画面を実装する"
                body.sizeToFit()
                body.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
                body.center = vc.view.center
                vc.view.addSubview(body)
                return TabPageViewController.PageInfo(menuItemView: view, vc: vc)
            }(),
        ]
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
        
        // 選択箇所に下線をつける
        let designView = UIView()
        designView.backgroundColor = .orange
        designView.center = menuBackground.center
        self.menuBackground.addSubview(designView)
        self.menuView.bringSubviewToFront(menuBackground)
        designView.translatesAutoresizingMaskIntoConstraints = false
        designView.bottomAnchor.constraint(equalTo: self.menuView.bottomAnchor).isActive = true
        designView.widthAnchor.constraint(equalTo: self.menuView.widthAnchor, multiplier: 1.0 / CGFloat(self.pageInfoList.count)).isActive = true
        designView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        // そのままmenuViewにグレーの色をつけてみる
        let unselectedDesignView = UIView()
        unselectedDesignView.backgroundColor = .lightGray
        unselectedDesignView.center = menuView.center
        self.menuView.addSubview(unselectedDesignView)
//        self.menuView.bringSubviewToFront(menuView)
        unselectedDesignView.translatesAutoresizingMaskIntoConstraints = false
        unselectedDesignView.bottomAnchor.constraint(equalTo: self.menuView.bottomAnchor).isActive = true
        unselectedDesignView.widthAnchor.constraint(equalTo: self.menuView.widthAnchor, multiplier: 1.0).isActive = true
        unselectedDesignView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
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
            // スクロール固定のためnilを返す
            return nil
        }
        return self.pageInfoList[index].vc
    }
    
    // 右隣のページ取得
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag - 1
        
        index += 1
        if index > self.pageInfoList.count - 1 {
            // スクロール固定のためnilを返す
            return nil
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
