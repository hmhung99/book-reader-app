//
//  ReviewViewController.swift
//  FileReader
//
//  Created by hung on 15/05/2021.
//

import UIKit
import Cosmos
import FBSDKLoginKit


protocol WriteReviewViewControllerDeletage {
    func doneReviewing ()
}

class ReviewViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var book: Book!
    var reviews: [Review] = []
    @IBAction func writeAReviewButtonPressed(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
        loadReviews()
    }
}

extension ReviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        let review = reviews[indexPath.row]
        cell.commentLabel.text = review.content
        cell.commentLabel.sizeToFit()
        cell.commentLabel.numberOfLines = 0
        cell.commentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.rateView.rating = Double(review.rate)
        cell.usernameLabel.text = review.user.name
        return cell
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! WriteReviewViewController
        destinationVC.book = book
        destinationVC.delegate = self
    }
    
    func loadReviews() {
        BookAPI.shared.getReviews(bookId: book.id) { (list) in
            DispatchQueue.main.async {
                self.reviews = list
                self.tableView.reloadData()
            }
        }
    }
}

extension ReviewViewController: WriteReviewViewControllerDeletage {
    func doneReviewing() {
        loadReviews()
    }
}

