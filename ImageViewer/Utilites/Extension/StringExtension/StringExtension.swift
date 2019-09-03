//
//  StringExtension.swift
//  ImageViewer
//
//  Created by Aman gupta on 02/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation

extension String {
    
    public func urlEncoded() -> String {
        let string = self
        
        var characterSet = NSMutableCharacterSet.urlQueryAllowed
        let delimitersToEncode = ":#[]@!$?&'()*+= "
        characterSet.remove(charactersIn: delimitersToEncode)
        
        return string.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet) ?? string
    }
    
}
