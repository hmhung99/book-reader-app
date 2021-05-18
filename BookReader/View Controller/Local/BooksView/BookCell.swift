//
//  BookCell.swift
//  FileReader
//
//  Created by hung on 25/04/2021.
//

import UIKit

class BookCell: UITableViewCell {

    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var likes: UIImageView!
    @IBOutlet weak var likesCount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        bookCover.contentMode = .scaleAspectFill
        bookCover.backgroundColor = UIColor.white
        bookCover.layer.cornerRadius = 8.0
        
        infoView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

