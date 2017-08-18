//
//  CaptivateUtils.swift
//  captivate
//
//  Created by Chethan Kumar on 12/21/16.
//  Copyright © 2016 Chethan Kumar. All rights reserved.
//

import Foundation

public class CaptivateUtils:NSObject{
    
    class func saveValueToNSUserDefaults (value:String, key:String){
        
        
        let standardUserDefaults : UserDefaults = UserDefaults.standard
        if standardUserDefaults.object(forKey: key) != nil  {
            
            UserDefaults.standard.set(value, forKey: key)
            UserDefaults.standard.synchronize()
            
        }
        
    }
    
    
    class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    class func convertToDictionaryArray(text: String) -> [[String: Any]]? {
        
        var arrayOfDict = [[String:Any]]()
        if let data = text.data(using: String.Encoding.utf8) {
            let json = JSON(data: data)
            
            for item in json.arrayValue {
                arrayOfDict.append(item.dictionaryObject!)
            }
        }
        
        return arrayOfDict
    }

}
