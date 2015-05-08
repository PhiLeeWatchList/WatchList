//
//  TableViewCell.swift
//  WatchList
//
//  Created by Lee Strasheim on 4/27/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    

    @IBOutlet weak var photo: UIImageView!

    
    @IBOutlet weak var name: UILabel!

    
    @IBOutlet weak var guid: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.photo.image = UIImage(named: "logo")
        self.photo.layer.cornerRadius = 20
        self.photo.layer.borderWidth = 1
        self.photo.layer.borderColor = UIColor.whiteColor().CGColor
        self.photo.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
