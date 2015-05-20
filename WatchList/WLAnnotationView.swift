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

    var imageBorderColor:UIColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
    var imageBgColor:UIColor = UIColor(red: 40.0/255.0, green: 0.0/255.0, blue: 221.0/255.0, alpha: 1)
    var textColor:UIColor = UIColor(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1)
    var tempSize:CGFloat = 40.0
    var userID:String!
    
    var centerImage:UIImageView!
    var centerLabel:UILabel!
}