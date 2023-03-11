//
//  Route.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/03/11.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import Foundation

struct Route {
    enum Scene {
        case readingWeb
        case login
        
        func rootIdentifier() -> String {
            switch self {
            case .readingWeb:
                return "WebViewControllerNavigationVC"
            case .login:
                return "TabPageViewControllerNavigationVC"
            }
        }
        
        func identifier() throws -> String {
            switch self {
            case .readingWeb:
                return "WebViewController"
            case .login:
                return "TabPageViewController"
            }
        }
    }
}
