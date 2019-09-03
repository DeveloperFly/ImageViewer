//
//  CommonUtils.swift
//  ImageViewer
//
//  Created by Aman gupta on 03/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

class CommonUtils {
     // MARK: - Debug logs
    class func debug_logs(arg: Any) {
        #if DEBUG
        print(arg)
        #endif
    }
    
    // Get dictionary from network data
    class func getDictionaryFromData(data: Data) -> [String: Any]? {
        do {
            let responseData = try JSONSerialization.jsonObject(with: data,
                                                                options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
            return responseData
        } catch let error {
            CommonUtils.debug_logs(arg: "json error: \(error.localizedDescription)")
            return nil
        }
    }
    
}
