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
        do
        {
            if let JSONData = JSONData
            {
                let json = try JSON(data: JSONData)
                print(json)
            }
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    open static func parseError(JSONString: String?)
    {
        let json = JSON(jsonString: JSONString!)
        
        print(json)
    }
}
