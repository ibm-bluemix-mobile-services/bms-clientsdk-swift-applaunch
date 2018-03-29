/*
 *     Copyright 2018 IBM Corp.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 */

//
//  AppLaunchInAppMessaging.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

internal class AppLaunchInAppMessaging: NSObject {
    
    private let action: MessageData
    private let BUTTONS:String = "buttons"
    private let TITLE:String = "title"
    private let SUB_TITLE:String = "subtitle"
    
    
    init(_ data: JSON) {
        self.action = MessageData.init(data[TITLE].stringValue, data[SUB_TITLE].stringValue, data[IMAGE_URL].stringValue, data[LAYOUT].stringValue, data[BUTTONS]);
    }
    
    func ShowBanner() -> Void {
        let BannerVC = PMAlertController(title: action.getTitle(), description: action.getSubTitle(), image: UIImage(data: action.getImage()), style: .walkthrough)  //.alert is smaller version
        
        for button in action.getButtonDataList() {
            BannerVC.addAction(PMAlertAction(title: button.getButtonName(), style: .default, action: { () -> Void in
                let metrics = button.getMetrics()
                var codes = [String]()
                for (_, metric) in metrics {
                    codes.append(metric[CODE].stringValue)
                }
                if (!codes.isEmpty) {
                    do {
                        try AppLaunch.sharedInstance.sendMetrics(codes: codes)
                    } catch {
                        print(MSG__ERR_NOT_INIT)
                    }
                }
            }))
        }
        BannerVC.show()
    }
}


internal enum MessageType : String {
    case Banner = "banner"
}

internal enum TriggerType : String {
    case FirstLaunch = "OnFirstAppLaunch"
    case EveryLaunch = "OnEveryAppLaunch"
    case EveryAlternateLaunch = "OnEveryAlternateAppLaunch"
    case OnceAndOnlyOnce = "OnceAndOnlyOnce"
}

internal class MessageData {
    private var image:String
    private var title:String
    private var subTitle:String
    private var buttonData:[ButtonData]?
    private var layout:String
    
    init(_ title:String,_ subTitle:String,_ image:String,_ layout:String,_ buttonData:JSON) {
        self.title = title
        self.subTitle = subTitle
        self.image = image
        self.layout = layout
        self.buttonData = processButtons(buttonData)
    }
    
    private func processButtons(_ data: JSON) -> [ButtonData]{
        var list = [ButtonData]()
        for (_, b1) in data {
            let button = ButtonData.init(b1[LABEL].stringValue, b1[ACTION].stringValue, b1[METRICS])
            list.append(button)
        }
        return list
    }
    
    
    func getImage() -> Data {
        var imageData:Data = Data()
        do {
            if(!image.isEmpty){
                imageData = try Data(contentsOf: URL(string: image)!)
            }
        } catch  {
        }
        return imageData
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getSubTitle() -> String {
        return subTitle
    }
    
    func getButtonDataList() -> [ButtonData]{
        return buttonData!
    }
    
}


internal class ButtonData {
    
    private var buttonName:String
    private var action:String
    private var metrics:JSON
    
    init(_ buttonName:String, _ action:String, _ metrics:JSON) {
        self.buttonName = buttonName
        self.action = action
        self.metrics = metrics
    }
    
    func getButtonName() -> String {
        return buttonName
    }
    
    func getMetrics() -> JSON {
        return metrics
    }
    
    func getAction() -> String {
        return action
    }
    
}
