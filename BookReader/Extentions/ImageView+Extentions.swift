//
//  ImageView+Extentions.swift
//  BookReader
//
//  Created by hung on 27/06/2021.
//

import Foundation
import UIKit

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
                print(error!.localizedDescription)
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

func loadRating(id: String, _ cell: BookCell) {
    async {
        let rating = await BookAPI.shared.getRating(id: id)
        DispatchQueue.main.async {
            if (rating != 0) {
                cell.ratingLabel.text = String(rating!)
                cell.ratingStarImage.image = UIImage(named: "ratingstar")
                cell.setNeedsLayout()
            }
        }
    }
}
