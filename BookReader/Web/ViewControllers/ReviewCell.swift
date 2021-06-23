//
//  ReviewCell.swift
//  FileReader
//
//  Created by hung on 15/05/2021.
//

import UIKit
import Cosmos

class ReviewCell: UITableViewCell {
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var rateView: CosmosView!
    
    @IBOutlet weak var commentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
