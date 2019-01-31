//
//  ConfigHelper.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/31.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

class SSBConfigHelper {
    
    static let shared = SSBConfigHelper()
    
    func initialization() -> Promise<Void> {
        return Promise(resolver: {  resolver in
            DispatchQueue.main.asyncAfter(deadline: 0, execute: {
                resolver.fulfill_()
            })
        })
    }
}
