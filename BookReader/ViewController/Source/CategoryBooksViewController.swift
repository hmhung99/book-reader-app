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
            cell.bookCover.loadImage(from: coverLink)
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
        } else {
            BookAPI.shared.getBooksByCategory(categoryId: categoryId) { (list) in
                DispatchQueue.main.async {
                    self.books = list
                    UIView.transition(with: self.tableView,
                                      duration: 1,
                                      options: .transitionCrossDissolve,
                                      animations: { self.tableView.reloadData() })
                }
            }
        }
    }
    
    func loadFavoriteBooks() {
        BookAPI.shared.getLikedBooks { (list) in
            DispatchQueue.main.async {
                self.books = list
                self.books = self.books.sorted { (i, j) -> Bool in
                    return i.name < j.name
                }
                UIView.transition(with: self.tableView,
                                  duration: 0.35,
                                  options: .transitionCrossDissolve,
                                  animations: { self.tableView.reloadData() })
            }
        }
    }
}


