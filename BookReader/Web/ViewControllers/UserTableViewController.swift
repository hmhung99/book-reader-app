//
//  UserTableViewController.swift
//  FileReader
//
//  Created by hung on 16/05/2021.
//

import UIKit
import FBSDKLoginKit

class UserTableViewController: UITableViewController {
    var categoiresLabel: [String] = ["My favorites", "Khoa Học", "Tiểu Thuyết", "Lịch Sử"]
    
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonPressed(_ sender: Any) {
        let loginManager = LoginManager()
        if let _ = AccessToken.current {
            loginManager.logOut()
            jwt = ""
            updateButton(isLoggedIn: false)
            NotificationCenter.default.post(name: NSNotification.Name.didLoginLogout, object: nil)
        } else {
            loginManager.logIn(permissions: [], from: self) { (result, error) in
                guard error == nil else {
                               // Error occurred
                               print(error!.localizedDescription)
                               return
                           }
                guard let result = result, !result.isCancelled else {
                                print("User cancelled login")
                                return
                            }
                self.updateButton(isLoggedIn: true)
                self.postUser(AccessToken.current!.tokenString)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButton(isLoggedIn: AccessToken.current != nil)
    
    }
    
    func postUser(_ accessToken: String) {
        async {
            jwt = await BookAPI.shared.getJWT(accessToken)
            NotificationCenter.default.post(name: NSNotification.Name.didLoginLogout, object: nil)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoiresLabel.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categoiresLabel[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toCategoryBooks", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! CategoryBooksViewController
            destinationVC.categoryId = indexPath.row
        }
    }
}

extension UserTableViewController {
    private func updateButton(isLoggedIn: Bool) {
            let title = isLoggedIn ? "Log out" : "Log in"
            loginButton.setTitle(title, for: .normal)
        }
}
