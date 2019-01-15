//
//  Utils.swift
//  StoreSearch
//
//  Created by human on 2019. 1. 15..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import Foundation

class Utils {
    
    static func isMainThread() {
        print("On the main thread? " + (Thread.current.isMainThread ? "Yes" : "No"))
    }
}
