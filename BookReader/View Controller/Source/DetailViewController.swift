//
//  DetailViewController.swift
//  FileReader
//
//  Created by hung on 08/05/2021.
//

import UIKit

class DetailViewController: UIViewController {

    var book: Book!
    var likesCount: Int = 0
    
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var donwloadImage: UIImageView!
    @IBOutlet weak var itemsView: UIView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBAction func downloadButtonPressed(_ sender: Any) {
        downloadBook()
        donwloadImage.image = UIImage(named: "checked")!
    }
    @IBAction func reviewButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toReviews", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ReviewViewController
        destinationVC.book = book
        
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        likeBook()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLikesImage(imageView: likesImageView, for: book.id)
        updateLikesCount(label: likesCountLabel, bookId: book.id)
        initView()
        
    }
    
    func initView() {
        cover.load(url: URL(string: book.bookCover!)!)
        cover.contentMode = .scaleAspectFill
        cover.backgroundColor = UIColor.white
        cover.layer.cornerRadius = 8.0
        backgroundImage.load(url: URL(string: book.bookCover!)!)
        backgroundImage.contentMode = .scaleToFill
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImage.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImage.addSubview(blurEffectView)
        itemsView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        itemsView.layer.cornerRadius = 8.0
        nameLabel.text = book.name
        authorLabel.text = book.author?.name
    }
    
    func downloadBook() {
        let alarm = URL(string: book.bookLink!)!
        do {
            try alarm.download(to: .documentDirectory, using: book.name) { url, error in
                guard let url = url else { return }
            }
        } catch {
            print(error)
        }
    }
    
    func likeBook() {
        let url = URL(string: "\(ip)/books/\(book.id)/likes")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue(jwt, forHTTPHeaderField: "user-token")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
            loadLikedBooks(imageView: self.likesImageView, bookId: self.book.id)
            updateLikesCount(label: self.likesCountLabel, bookId: self.book.id)
            
        }
        task.resume()
    }
}

func updateLikesImage(imageView: UIImageView, for bookId: String) {
    if isLiked(id: bookId) {
        imageView.image = UIImage(named: "liked")
    } else {
        imageView.image = UIImage(named: "like")
    }
}

func updateLikesCount(label: UILabel, bookId: String) {
    let url = URL(string: "\(ip)/books/\(bookId)/likes")!
    var request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let data = data {
            if let response = try? JSONDecoder().decode(Int.self, from:data) {
                DispatchQueue.main.async {
                    label.text = String(response)
                }
            }
        }
    }.resume()
}

extension URL {
    func download(to directory: FileManager.SearchPathDirectory, using fileName: String? = nil, overwrite: Bool = false, completion: @escaping (URL?, Error?) -> Void) throws {
        let directory = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destination: URL
        if let fileName = fileName {
            destination = directory
                .appendingPathComponent(fileName + ".epub")
                .appendingPathExtension(self.pathExtension)
        } else {
            destination = directory
            .appendingPathComponent(lastPathComponent + ".epub")
        }
        if !overwrite, FileManager.default.fileExists(atPath: destination.path) {
            completion(destination, nil)
            return
        }
        URLSession.shared.downloadTask(with: self) { location, _, error in
            guard let location = location else {
                completion(nil, error)
                return
            }
            do {
                if overwrite, FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.moveItem(at: location, to: destination)
                completion(destination, nil)
            } catch {
                print(error)
            }
        }.resume()
    }
}

