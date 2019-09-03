//
//  NSObjectExtension.swift
//  ImageViewer
//
//  Created by Aman gupta on 02/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation

extension NSObject {
    static func className() -> String {
        return String(describing : self)
    }
    
}
