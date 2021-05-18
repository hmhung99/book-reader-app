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
        let font = UIFont(name: "Helvetica", size: 20.0)!
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    
}
