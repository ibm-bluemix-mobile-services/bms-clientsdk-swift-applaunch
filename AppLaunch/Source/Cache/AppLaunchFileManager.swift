//
//  AppLaunchFileManager.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON


internal class AppLaunchFileManager {
    
    // TODO : Handle Duplicate files & Optimize logic to fetch only JSON files
    class func readJSONFiles() -> [String]? {
        let fileManager = FileManager.init();
        let applicationPath = Bundle.main.bundlePath;
        do {
            let filesList = try fileManager.contentsOfDirectory(atPath: applicationPath);
            let filteredfileList = filesList.filter { file in
                return file.lowercased().hasPrefix(SERVICE_NAME) && file.lowercased().hasSuffix(JSON_PATH_EXTENSION);
            }
            return filteredfileList;
        } catch {
            print(error)
        }
        return nil;
    }
    
    class func readJSONwith(fileName: String) -> JSON? {
        let filePath = Bundle.main.path(forResource: fileName.replacingOccurrences(of: JSON_PATH_EXTENSION, with: ""), ofType: JSON_NAME);
        if (filePath != nil) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath!), options: .alwaysMapped)
                return JSON(data: data);
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else{
            print("Invalid filename/path.")
        }
        return nil;
    }
   
}
