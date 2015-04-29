//
//  User.swift
//  WatchList
//
//  Created by Lee Strasheim on 4/28/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var guid: String
    @NSManaged var image: NSData

}
