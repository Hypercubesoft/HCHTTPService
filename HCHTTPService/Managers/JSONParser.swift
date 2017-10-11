//
//  JSONParser.swift
//
//  Created by Hypercube on 12/19/16.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import Foundation
import SwiftyJSON

open class JSONParser {

    // MARK: - ERROR
    open static func parseError(JSONData: Data?)
    {
        let json = JSON(data: JSONData!)

        print(json)
    }
    
    open static func parseError(JSONString: String?)
    {
        let json = JSON(jsonString: JSONString!)
        
        print(json)
    }
}
