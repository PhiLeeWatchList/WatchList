//
//  WLAnnotationView.swift
//  WatchList
//
//  Created by Phil Starner on 5/20/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import Foundation
import MapKit

class WLAnnotationView: MKAnnotationView {

    //var borderColor:UIColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
    var borderColor:UIColor = UIColor.grayColor()
    var bgColor:UIColor = UIColor(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1)
    var size:CGFloat = 40.0
    var userID:String!
    
    var centerImage:UIImageView!
    var centerLabel:UILabel!
}