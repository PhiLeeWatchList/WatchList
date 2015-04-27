//
//  User.swift
//  WatchList
//
//  Created by Lee Strasheim on 4/27/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit

class User : NSObject, NSCoding {
    var guid : String
    var first : String
    var last : String
    
    init (guid:String, first:String, last:String) {
        self.guid = guid
        self.first = first
        self.last = last
    }
    
    // MARK: NSCoding
    
    required init(coder decoder: NSCoder) {
        //Error here "missing argument for parameter name in call
        self.guid = decoder.decodeObjectForKey("guid") as! String
        self.first = decoder.decodeObjectForKey("first") as! String
        self.last = decoder.decodeObjectForKey("last") as! String
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.guid, forKey: "guid")
        coder.encodeObject(self.first, forKey: "first")
        coder.encodeObject(self.last, forKey: "last")

        
    }
}
