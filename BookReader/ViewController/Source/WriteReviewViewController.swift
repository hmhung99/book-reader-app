//
//  WriteReviewViewController.swift
//  FileReader
//
//  Created by hung on 17/05/2021.
//

import UIKit
import Cosmos

class WriteReviewViewController: UIViewController {

    var book: Book!
    var delegate: WriteReviewViewControllerDeletage?
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var rateView: CosmosView!
    @IBAction func sendButtonPressed(_ sender: Any) {
        if let comment = textView.text {
            BookAPI.shared.postReview(bookId: book.id, comment, Float(rateView.rating)) { (data) in
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isEnabled = false
        rateView.didFinishTouchingCosmos = { rating in
            self.sendButton.isEnabled = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.doneReviewing()
    }
    
}


