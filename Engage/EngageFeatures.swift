//
//  EngageFeatures.swift
//  Engage
//
//  Created by Chethan Kumar on 8/5/17.
//  Copyright © 2017 Chethan Kumar. All rights reserved.
//

import Foundation

public class EngageFeatures: NSObject {
    
    private var features : JSON
    
    public init(featureSet:JSON){
        self.features = featureSet
    }
    
    public func hasFeatureWith(code:String) -> Bool{
        var hasFeature = false
        for(key,feature) in features{
            if let featureCode = feature["code"].string{
                if featureCode == code{
                    hasFeature = true
                }
            }
        }
        return hasFeature
    }
    
    public func getValueFor(featureWithCode:String,variableWithCode:String) -> String{
        for(key,feature) in features{
            if let featureCode = feature["code"].string{
                if featureCode == featureWithCode{
                    for(k,variable) in feature["variables"]{
                        if let varibleCode = variable["code"].string{
                            if varibleCode == variableWithCode{
                                return variable["value"].stringValue
                            }
                        }
                    }
                }
            }
        }
        return ""
    }
}
