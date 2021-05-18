//
//  BookSourceViewController.swift
//  FileReader
//
//  Created by hung on 01/05/2021.
//

import UIKit
import EPUBKit
import SwiftyJSON
import FBSDKLoginKit

let ip = "http://192.168.1.105:8080"
var likedBooks: [Book] = []

class BookSourceViewController: UITableViewController, UISearchBarDelegate {
    var books: [Book] = []
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userButtonPressed: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadAllBooks()
    }
    
    override func viewDidLoad() {
        searchBar.delegate = self
        self.tableView.separatorStyle = .none
        var content: Content? = nil
        tableView.register(UINib(nibName: "BookCell", bundle: nil), forCellReuseIdentifier: "BookSourceCell")
        loadAllBooks()
        
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BookSourceCell", for: indexPath) as! BookCell
        
        let book = books[indexPath.row]
        cell.label.text = book.name
        cell.author.text = book.author?.name
        cell.category.text = book.category?.name
        cell.likesCount.text = String(book.reactionNum)
        if let coverLink = book.bookCover {
            cell.bookCover.load(url: URL(string: coverLink)!)
        } else {
            cell.bookCover.image = UIImage(named: "oldback")
        }
        updateLikesImage(imageView: cell.likes, for: book.id)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.book = books[indexPath.row]
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

    }
    

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    
    }



    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if let name = searchBar.text {
            print(name)
            loadByName(name)
        }
    }
    
    func loadAllBooks() {
        books = []
        let url = URL(string: "\(ip)/books?page=0&size=40")
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let response = try? JSONDecoder().decode(Content.self, from:data) {
                    DispatchQueue.main.async {
                        self.books = response.content!
                        self.tableView.reloadData()
                    }
                }
            }
        }.resume()
    }
    
    func loadByName(_ name: String) {
        books = []
        if let url = URL(string: "\(ip)/books/?name=\(name)"
                            .addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!) {
            print(url)
            var request = URLRequest(url: url)
            request.setValue(jwt, forHTTPHeaderField: "user-token")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    print(data)
                    if let response = try? JSONDecoder().decode([Book].self, from:data) {
                        DispatchQueue.main.async {
                            self.books = response
                            self.books = self.books.sorted(by: { (i, j) -> Bool in
                                return i.name < j.name
                            })
                            self.tableView.reloadData()
                        }
                    }
                }
            }.resume()
        }
        if books.count == 0 {
            self.tableView.reloadData()
        }
    }
    
    
}



func isLiked(id: String) -> Bool {
    if likedBooks.contains(where: {$0.id == id}) {
        return true
    }
    return false
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


    

    







