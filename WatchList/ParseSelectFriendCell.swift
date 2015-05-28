//
//  ParseSelectFriendCell.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/28/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ParseSelectFriendCell: PFTableViewCell {


    @IBOutlet weak var profileImage: PFImageView!

    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
