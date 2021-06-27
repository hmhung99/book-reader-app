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

class BookSourceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var books: [Book] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userButtonPressed: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        checkLogin()
        initView()
    }
    
    func initView() {
        loadAllBooks()
        searchBar.delegate = self
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = view.backgroundColor?.cgColor
        
        navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()
        tabBarController?.tabBar.layer.borderWidth = 0.1
        tabBarController?.tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBarController?.tabBar.clipsToBounds = true

        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 137
        tableView.register(UINib(nibName: "BookCell", bundle: nil), forCellReuseIdentifier: "BookSourceCell")
        NotificationCenter.default.addObserver(self, selector: #selector(loadAllBooks), name: NSNotification.Name.tapLikeBook, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadLikedBooks), name: NSNotification.Name.didLoginLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadAllBooks), name: NSNotification.Name.didLoginLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadAllBooks), name: NSNotification.Name.finishReview, object: nil)
    }


     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.book = books[indexPath.row]
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if let keyword = searchBar.text {
            loadByKeyword(keyword)
        }
    }
    
    @objc func loadAllBooks() {
        async {
            self.books = await BookAPI.shared.getAllBooks()
            updateUI()
        }
    }
    
    @objc func loadLikedBooks() {
        async {
            likedBooks = await BookAPI.shared.getLikedBooks()
            updateUI()
        }
        
    }
    
    func loadByKeyword(_ keyword: String) {
        async {
            self.books = await BookAPI.shared.getBooksByKeyword(keyword)
            updateUI()
        }
        
    }
    
    func checkLogin() {
        if let accessToken = AccessToken.current?.tokenString {
            async {
                jwt = await BookAPI.shared.getJWT(accessToken)
                loadLikedBooks()
            }
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

    

    







