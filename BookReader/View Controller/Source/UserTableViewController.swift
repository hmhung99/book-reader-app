//
//  UserTableViewController.swift
//  FileReader
//
//  Created by hung on 16/05/2021.
//

import UIKit
import FBSDKLoginKit

class UserTableViewController: UITableViewController {

    @IBOutlet weak var logOutButton: UIButton!
    
    var categoiresLabel: [String] = ["My favorites", "Khoa Học", "Tiểu Thuyết", "Lịch Sử"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = FBLoginButton()
        logOutButton.addSubview(loginButton)
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
