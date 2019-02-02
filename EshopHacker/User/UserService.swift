//
//  UserService.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/28.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

class UserService: NSObject, WXApiDelegate {
    
    static let shared = UserService()
    
    private var authorizeCode = ""
    
    func weChatLogin() {
        
        enum LoginError: Error {
            case sendReqError
        }
    }
    
    private func fetchAuthorizeCode() -> Promise<String> {
        return Promise(resolver: { resolver in
            DispatchQueue.global().async {
                while self.authorizeCode.isEmpty {}
            }
            resolver.fulfill(self.authorizeCode)
        })
    }
    
    private func loginRequest() -> Promise<Bool> {
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "App"
        return Promise.value(WXApi.send(req))
    }
    
    // MARK: WXApiDelegate
    func onReq(_ req: BaseReq) {
        
    }
    
    func onResp(_ resp: BaseResp) {
        print(resp)
    }
}
