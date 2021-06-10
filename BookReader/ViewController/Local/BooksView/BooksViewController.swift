//
//  BooksViewController.swift
//  FileReader
//
//  Created by hung on 25/04/2021.
//

import UIKit
import EPUBKit

class BooksViewController: UITableViewController {
    var books: [EPUBDocument] = []
    var bookURLs: [URL] = []
    
    
    // *********temporary*******
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        books = []
        bookURLs = getBookURLs()
        bookURLs.forEach { (url) in
            books.append(EPUBDocument(url: url)!)
        }
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        let height: CGFloat = 100 //whatever height you want to add to the existing height
        tableView.register(UINib(nibName: "BookCell", bundle: nil), forCellReuseIdentifier: "BookCell")
        
        bookURLs = getBookURLs()
        bookURLs.forEach { (url) in
            books.append(EPUBDocument(url: url)!)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
        let info = books[indexPath.row]
        cell.label.text = info.title
        cell.author.text = info.author
        let image =  UIImage(contentsOfFile: info.cover!.path)
        cell.bookCover.image = image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toEpub", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletetAlert = UIAlertController(title: "Delete \(books[indexPath.row].title!)", message: "All data will be lost.", preferredStyle: UIAlertController.Style.alert)

            deletetAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [self] (action: UIAlertAction!) in
                let fileManager = FileManager.default
                try? fileManager.removeItem(at: self.bookURLs[indexPath.row])
                self.books.remove(at: indexPath.row)
                bookURLs.remove(at: indexPath.row)
                tableView.reloadData()
            }))

            deletetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                  print("Handle Cancel Logic here")
            }))

            present(deletetAlert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedBook = bookURLs[indexPath.row]
            let destinationVC = segue.destination as! EpubViewController
            destinationVC.fileName = selectedBook.lastPathComponent
        }
    }
    
    func getBookURLs() -> [URL] {
        var urls = [URL]()
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            fileURLs.forEach { (url) in
                if url.lastPathComponent.contains(".epub") {
                    urls.append(url)
                }
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        return urls
    }

}
