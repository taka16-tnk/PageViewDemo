//
//  WebDataState.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/03/16.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import Foundation

class WebDataState {
    var isLogin = false
    var isClose = false
    
    static let sharedInstance = WebDataState()
}
