//
//  AppLaunchInvoker.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import BMSCore
import SwiftyJSON

internal class AppLaunchInvoker: NSObject {
    private var url:String
    private var method:HttpMethod
    private var timeout:TimeInterval
    private var headers = [String:String]()
    private var queryParameters = [String:String]()
    private var requestBody:Data? = nil
    private var completionHandler:BMSCompletionHandler? = nil
    
    init(url:String, method:HttpMethod, timeout : TimeInterval) {
        self.url = url
        self.method = method
        self.timeout = timeout
    }
    
    func execute() {
        let request = Request(url: url, method: method, headers: headers, queryParameters: queryParameters, timeout: timeout)
        if (requestBody != nil) {
            request.send(requestBody: requestBody, completionHandler: completionHandler)
        } else {
            request.send(completionHandler: completionHandler)
        }
    }
    
    func setCompletionHandler(_ completionHandler: @escaping BMSCompletionHandler) {
        self.completionHandler = completionHandler
    }
    
    func setJSONRequestBody(_ data: JSON) {
        self.requestBody = data.description.data(using: .utf8)
    }
    
    func addHeader(_ headerName:String,_ headerValue:String) {
        self.headers.updateValue(headerName, forKey: headerValue)
    }
    
    func addQueryParameter(_ name:String,_ value:String) {
        self.queryParameters.updateValue(name, forKey: value)
    }
}
