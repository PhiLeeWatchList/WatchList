//
//  CustomCell.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/27/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class CustomCell: PFTableViewCell {


    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
}
