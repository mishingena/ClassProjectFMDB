//
//  FruitModel.swift
//  ClassProjectFMDB
//
//  Created by Gena on 18.03.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class FruitModel: NSObject {
    var fruitId: Int
    var name: String
    var details: String
    var imageURL: NSURL
    var thumbURL: NSURL
    
    init(set: FMResultSet) {
        fruitId = set.longForColumn("id")
        name = set.stringForColumn("name")
        details = set.stringForColumn("details")
        thumbURL = NSURL(string: set.stringForColumn("thumb_url"))!
        imageURL = NSURL(string: set.stringForColumn("image_url"))!
    }
    
    func dictionary() -> Dictionary<String,String> {
        return ["id":String(fruitId), "title":name, "details":details, "thumb":thumbURL.absoluteString!, "img":imageURL.absoluteString!]
    }
   
}
