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
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var rateView: CosmosView!
    @IBAction func sendButtonPressed(_ sender: Any) {
        if let comment = textView.text {
            async {
                await BookAPI.shared.postReview(bookId: book.id, comment, Float(rateView.rating))
                NotificationCenter.default.post(name: NSNotification.Name.finishReview, object: nil)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isEnabled = false
        rateView.didFinishTouchingCosmos = { rating in
            self.sendButton.isEnabled = true
        }
    }
    
}


