//
//  LoginViewController.swift
//  FileReader
//
//  Created by hung on 11/05/2021.
//

import UIKit
import FBSDKLoginKit

var jwt: String = ""
class LoginViewController: UIViewController {
     
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if AccessToken.current != nil {
            let accessToken = AccessToken.current?.tokenString
            postUser(accessToken!)
        }
        else {
            let loginButton = FBLoginButton()
            loginButton.center = view.center
            view.addSubview(loginButton)
            NotificationCenter.default.addObserver(forName: .AccessTokenDidChange, object: nil, queue: OperationQueue.main) { (notification) in
                if let accessToken = AccessToken.current?.tokenString {
                    self.postUser(accessToken)
                }
            }
            
        }
        
    }
    
    func postUser(_ accessToken: String)  {
        // prepare json data
        let json: [String: Any] = ["accessToken": "\(accessToken)"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: "\(ip)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        // insert json data to the request
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let responseJSON = responseJSON as? [String: Any] {
                DispatchQueue.main.async {
                    jwt = responseJSON["jwt"] as! String
                    loadLikedBooks()
                    self.performSegue(withIdentifier: "toSource", sender: self)
                }
            }
        }.resume()
    }
}

func loadLikedBooks(imageView: UIImageView = UIImageView(), bookId: String = "ewrwq") {
    likedBooks = []
    let url = URL(string: "\(ip)/books/likes")
    var request = URLRequest(url: url!)
    print("jwt" + jwt)
    request.setValue(jwt, forHTTPHeaderField: "user-token")
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let data = data {
            if let response = try? JSONDecoder().decode(FavoriteBooks.self, from:data) {
                likedBooks = response.favoriteBooks ?? []
                DispatchQueue.main.async {
                    updateLikesImage(imageView: imageView, for: bookId)
                }
                
            }
        }
    }.resume()
}

