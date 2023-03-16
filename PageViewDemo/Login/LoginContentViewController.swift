//
//  LoginContentViewController.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/02/26.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit

class LoginContentViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func tapLoginBtn(_ sender: Any) {
        // Userdefaultへ保存
        let writtenUser = userName.text! as NSString
        let writtenPass = inputPassword.text! as NSString
        
        let defaults = UserDefaults.standard
        defaults.set(writtenUser, forKey: "id")
        defaults.set(writtenPass, forKey: "pass")
        view.endEditing(true)
        // コンソールに表示
        print("ID:\(defaults.string(forKey: "id")!)")
        print("PW:\(defaults.string(forKey: "pass")!)")
        
        // 簡易的なログイン状態フラグを立てる
        WebDataState.sharedInstance.isLogin = true
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
