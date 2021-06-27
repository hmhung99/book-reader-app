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
        async {
            let _ = await BookAPI.shared.postLike(id: book.id)
            self.loadLikedBooks()
            loadBook()
            NotificationCenter.default.post(name: NSNotification.Name.tapLikeBook, object: nil)
        }
        
    }
    
    func loadBook() {
        async {
            let response = await BookAPI.shared.getBookById(id: book.id)
            DispatchQueue.main.async {
                self.likesCountLabel.text = String(response!.reactionNum)
            }
        }
    }
    
    func loadLikedBooks() {
        async {
            likedBooks = await BookAPI.shared.getLikedBooks()
            DispatchQueue.main.async {
                updateLikesImage(imageView: self.likesImageView, for: self.book.id)
            }
        }
    }

}



