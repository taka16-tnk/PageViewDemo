//
//  ViewController.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/02/23.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // メモリ警告を受け取った時に呼び出されるメソッド
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    
//    @IBAction func moveToOriginal(_ sender: UIButton) {
//
//        let vc = TabPageViewController()
//
//        // ページ情報
//        vc.pageInfoList = [
//            {
//                let view = TextViewMenuItemView()
////                view.backgroundColor = .red
//                view.title = "ログイン"
//                view.parent = vc
////                let vc = UIViewController()
//                let vc = LoginContentViewController()
//                let body = UILabel()
//                body.text = "ログイン画面を実装する"
//                body.sizeToFit()
//                body.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
//                body.center = vc.view.center
//                vc.view.addSubview(body)
//                return TabPageViewController.PageInfo(menuItemView: view, vc: vc)
//            }(),
//            {
//                let view = TextViewMenuItemView()
////                view.backgroundColor = .green
//                view.title = "新規登録"
//                view.parent = vc
//                let vc = UIViewController()
////                vc.view.backgroundColor = .green
//                let body = UILabel()
//                body.text = "新規登録画面を実装する"
//                body.sizeToFit()
//                body.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
//                body.center = vc.view.center
//                vc.view.addSubview(body)
//                return TabPageViewController.PageInfo(menuItemView: view, vc: vc)
//            }(),
//        ]
//
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
}

