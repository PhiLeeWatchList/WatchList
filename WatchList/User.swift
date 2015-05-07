//
//  User.swift
//  
//
//  Created by Lee Strasheim on 5/6/15.
//
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var firstName: String
    @NSManaged var guid: String
    @NSManaged var image: NSData
    @NSManaged var lastName: String
    @NSManaged var selected: NSNumber
    @NSManaged var id: String
    @NSManaged var username: String

}
