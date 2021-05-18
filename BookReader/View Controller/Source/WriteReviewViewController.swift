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
            postReview(comment, Float(rateView.rating))
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isEnabled = false
        rateView.didFinishTouchingCosmos = { rating in
            self.sendButton.isEnabled = true
        }
    }
    
    func postReview(_ comment: String, _ rate: Float)  {
        // prepare json data
        let json: [String: Any] = ["content": "\(comment)", "rate": rate]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // create post request
        print(jsonData)
        let url = URL(string: "\(ip)/books/\(book.id)/reviews")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue(jwt, forHTTPHeaderField: "user-token")
        // insert json data to the request
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let responseJSON = responseJSON as? [String: Any] {
    //                     responseJSON["jwt"] as! String
            
            }
        }
        task.resume()
    }


}
