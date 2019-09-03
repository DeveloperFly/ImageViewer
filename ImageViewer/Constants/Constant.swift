//
//  Constant.swift
//  ImageViewer
//
//  Created by Aman gupta on 03/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

struct Constant {
    static let searchImages = "Search Images"
    static let changeNumberOfColumns = "Change number of columns"
    static let two = "2"
    static let three = "3"
    static let four = "4"
    static let errorMessage = "Error Occurred"
    static let ok = "Ok"
    static let hudDefaultText = "Please Wait..."
    static let errorMessageSomethingWrong = "Something went wrong."

    struct Storyboard {
        static let main = "Main"
    }
    
    struct ViewController {
        static let defaultNumberOfColumns = 3
    }
    
}

// MARK: - Common API keys
enum APIKeys: String {
    case kAPIError = "error"
}

// MARK: - Singlnton Objects
let kAppDelegate = UIApplication.shared.delegate as! AppDelegate
let kUserDefaults = UserDefaults.standard

