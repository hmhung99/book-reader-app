//
//  BookSourceViewController.swift
//  FileReader
//
//  Created by hung on 01/05/2021.
//

import UIKit
import EPUBKit
import FBSDKLoginKit


var likedBooks: [Book] = []

class BookSourceViewController: UITableViewController, UISearchBarDelegate {
    var books: [Book] = []
    var jwtObserve: String? {
        didSet {
            loadLikedBooks()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userButtonPressed: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        checkLogin()
        loadAllBooks()
    }
    
    override func viewDidLoad() {
        searchBar.delegate = self
        self.tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "BookCell", bundle: nil), forCellReuseIdentifier: "BookSourceCell")
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
            cell.bookCover.loadImage(from: coverLink)
        } else {
            cell.bookCover.image = UIImage(named: "placeholderbook")
        }
        updateLikesImage(imageView: cell.likes, for: book.id)
        if !book.reviews!.isEmpty {
            loadRating(id: book.id, cell)
        } else {
            cell.ratingStarImage.image = nil
            cell.ratingLabel.text = ""
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        UIView.animate(
            withDuration: 0.35,
            delay: 0.00005 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
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
        if let keyword = searchBar.text {
            loadByKeyword(keyword)
        }
    }
    
    func loadAllBooks() {
        loadLikedBooks()
        BookAPI.shared.getAllBooks { (list) in
            DispatchQueue.main.async {
                self.books = list
                UIView.transition(with: self.tableView,
                                  duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: { self.tableView.reloadData() })
            }
        }
    }
    
    func loadLikedBooks() {
        BookAPI.shared.getLikedBooks { (list) in
            DispatchQueue.main.async {
                likedBooks = list
            }
        }
    }
    
    func loadByKeyword(_ keyword: String) {
        BookAPI.shared.getBooksByKeyword(keyword) { (list) in
            DispatchQueue.main.async {
                self.books = list
                UIView.transition(with: self.tableView,
                                  duration: 0.2,
                                  options: .transitionCrossDissolve,
                                  animations: { self.tableView.reloadData() })
            }
        }
    }
    
    func checkLogin() {
        if let accessToken = AccessToken.current?.tokenString {
            BookAPI.shared.getJWT(accessToken) { (response) in
                DispatchQueue.main.async {
                    jwt = response
                    self.jwtObserve = response
                }
            }
        }
        
    }
    
    
    
}

func loadRating(id: String, _ cell: BookCell) {
    BookAPI.shared.getRating(id: id) { (rating) in
        DispatchQueue.main.async {
            if (rating != 0) {
                cell.ratingLabel.text = String(rating)
                cell.ratingStarImage.image = UIImage(named: "ratingstar")
                cell.setNeedsLayout()
            }
        }
    }
}




let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    func loadImage(from path: String) {
        let url = URL(string: path)!
        self.image = nil
        
        if let imageFromCache = imageCache.object(forKey: path as NSString) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                let imageToCache = UIImage(data: data!)
                self.image = imageToCache
                imageCache.setObject(imageToCache!, forKey: path as NSString)
                
            }
        }.resume()
    }
}

    

    







