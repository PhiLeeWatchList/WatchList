//
//  CustomCell.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/27/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit

class ParseFriendCell: PFTableViewCell {


    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
