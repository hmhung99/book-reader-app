//
//  Book.swift
//  FileReader
//
//  Created by hung on 07/05/2021.
//

import Foundation

struct Content: Codable {
    let content: [Book]?
}

struct FavoriteBooks: Codable {
    let favoriteBooks: [Book]?
}

struct Book: Codable {
    let id: String
    let name: String
    let description: String?
    let bookLink: String?
    let bookCover: String?
    let reactionNum: Int
    let viewNum: Int
    let author: Author?
    var publisher: Publisher?
    let category: Category?
    let free: Bool
    let reviews: [Review]?
}

struct Author: Codable {
    let id: Int
    let name: String
    let description: String
}

struct Publisher: Codable {
    let id: Int
    let name: String
    let description: String
}

struct Category: Codable {
    let id: Int
    let name: String
    let books: [Book]?
}

struct ListReviews: Codable {
    let reviews: [Review]
}

struct Review: Codable {
    let id: String
    let rate: Float
    let content: String
    let user: User
    let book: Book
}

struct User: Codable {
    let id: String
    let name: String
    let facebookUserId: String
}

