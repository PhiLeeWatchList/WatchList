//
//  UserTableViewCell.swift
//  WatchList
//
//  Created by Lee Strasheim on 6/9/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var profilepic: PFImageView!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
