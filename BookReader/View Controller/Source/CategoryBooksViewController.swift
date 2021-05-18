//
//  CategoryBooksViewController.swift
//  FileReader
//
//  Created by hung on 16/05/2021.
//

import UIKit

class CategoryBooksViewController: UITableViewController {

    var books: [Book] = []
    var categoryId = 0
    
    override func viewWillAppear(_ animated: Bool) {
        loadBooksByCategory()
        self.tableView.separatorStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "BookCell", bundle: nil), forCellReuseIdentifier: "categoryBooksCell")
        loadBooksByCategory()
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryBooksCell", for: indexPath) as! BookCell

        let book = books[indexPath.row]
        cell.label.text = book.name
        cell.author.text = book.author?.name
        cell.category.text = book.category?.name
        cell.likes.image = UIImage(named: "like-icon")
        cell.likesCount.text = String(book.reactionNum)
        if let coverLink = book.bookCover {
            cell.bookCover.load(url: URL(string: coverLink)!)
        } else {
            cell.bookCover.image = UIImage(named: "oldback")
        }
        updateLikesImage(imageView: cell.likes, for: book.id)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToDetails", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.book = books[indexPath.row]
        }
    }

    
    func loadBooksByCategory() {
        books = []
    
        if categoryId == 0 {
            loadFavoriteBooks()
        }
        
        let url = URL(string: "\(ip)/categories/\(categoryId)")
        var request = URLRequest(url: url!)
        request.setValue(jwt, forHTTPHeaderField: "user-token")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let response = try? JSONDecoder().decode(Category.self, from:data) {
                    DispatchQueue.main.async {
                        self.books = response.books ?? []
                        self.tableView.reloadData()
                    }
                }
            }
        }.resume()
    }
    
    func loadFavoriteBooks() {
        let url = URL(string: "\(ip)/books/likes")
        var request = URLRequest(url: url!)
        request.setValue(jwt, forHTTPHeaderField: "user-token")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let response = try? JSONDecoder().decode(FavoriteBooks.self, from:data) {
                    DispatchQueue.main.async {
                        self.books = response.favoriteBooks ?? []
                        self.books = self.books.sorted { (i, j) -> Bool in
                            return i.name < j.name
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }.resume()
    }
}
