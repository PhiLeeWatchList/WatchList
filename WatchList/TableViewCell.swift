//
//  TableViewCell.swift
//  WatchList
//
//  Created by Lee Strasheim on 4/27/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var initials: UILabel!

    
    @IBOutlet weak var name: UILabel!

    
    @IBOutlet weak var guid: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
