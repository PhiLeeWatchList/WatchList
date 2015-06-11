//
//  TableViewCell.swift
//  WatchList
//
//  Created by Lee Strasheim on 6/10/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class TableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var profileImage: PFImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
