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
        likesCountLabel.text = String(book.reactionNum)
        print(jwt)
        initView()
        
    }
    
    func initView() {
        cover.loadImage(from: book.bookCover!)
        cover.contentMode = .scaleAspectFill
        cover.backgroundColor = UIColor.white
        cover.layer.cornerRadius = 8.0
        backgroundImage.loadImage(from: book.bookCover!)
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
//                guard let url = url else { return }
            }
        } catch {
            print(error)
        }
    }
    
    func likeBook() {
        BookAPI.shared.postLike(id: book.id) { (data) in
            DispatchQueue.main.async {
                self.loadBook()
                self.loadLikedBooks()
            }
        }
    }
    
    func loadBook() {
        BookAPI.shared.getBookById(id: book.id) { (object) in
            DispatchQueue.main.async {
                self.likesCountLabel.text = String(object.reactionNum)
            }
        }
    }
    
    func loadLikedBooks() {
        BookAPI.shared.getLikedBooks { (list) in
            DispatchQueue.main.async {
                likedBooks = list
                updateLikesImage(imageView: self.likesImageView, for: self.book.id)
            }
        }
    }

}

func updateLikesImage(imageView: UIImageView, for bookId: String) {
    if isLiked(id: bookId) {
        imageView.image = UIImage(named: "liked")
    } else {
        imageView.image = UIImage(named: "like")
    }
}

func isLiked(id: String) -> Bool {
    if likedBooks.contains(where: {$0.id == id}) {
        return true
    }
    return false
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
