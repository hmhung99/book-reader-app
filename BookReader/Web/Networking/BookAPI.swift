//
//  BookAPI.swift
//  BookReader
//
//  Created by hung on 30/05/2021.
//

import Foundation

var jwt: String = ""
class BookAPI {
    let base = "http://192.168.1.105:8080"
    static let shared = BookAPI()
}

extension BookAPI {
    
    func getAllBooks() async -> [Book] {
        let path = base + "/books?page=0&size=40"
        let response = await get(from: path, type: Content.self)
        return response?.content ?? []
    }
    
    func getBookById(id: String) async -> Book? {
        let path = base + "/books/\(id)"
        let response = await get(from: path, type: Book.self)
        return response
    }
    
    func getLikedBooks() async -> [Book] {
        let path = base + "/books/likes"
        let response = await get(from: path, type: FavoriteBooks.self)
        return response?.favoriteBooks ?? []
    }
    
    func getBooksByKeyword(_ keyword: String) async -> [Book]  {
        let path = base + "/books?page=0&name=\(keyword)"
            .addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let response = await get(from: path, type: Content.self)
        return response?.content ?? []
    }
    
    func getBooksByCategory(categoryId: Int) async -> [Book]  {
        let path = base + "/categories/\(categoryId)"
        let response = await get(from: path, type: Category.self)
        return response?.books ?? []
        
    }
    
    func getReviews(bookId: String) async -> [Review] {
        let path = base + "/books/\(bookId)/reviews"
        let response = await get(from: path, type: ListReviews.self)
        return response?.reviews ?? []
        
    }
    
    func getRating(id: String) async -> Float?  {
        let path = base + "/books/\(id)/rateAverage"
        let response = await get(from: path, type: Float.self)
        return response
    }
    
    func postLike(id: String) async -> Bool {
        let path = base + "/books/\(id)/likes"
        let _ =  await post(from: path)
        return true
    }
    
    func postReview(bookId: String, _ comment: String, _ rate: Float) async {
        let path = base + "/books/\(bookId)/reviews"
        let json: [String: Any] = ["content": "\(comment)", "rate": rate]
        let _ =  await post(from: path, json: json)
    }
    
    func getJWT(_ accessToken: String) async -> String {
        let path = base + "/users"
        let json: [String: Any] = ["accessToken": "\(accessToken)"]
        let data =  await post(from: path, json: json)
        let response = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
        let jwt = response["jwt"] as! String
        return jwt
        
    }
    
    
    func get<T: Decodable>(from path: String, type: T.Type) async -> T? {
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        request.setValue(jwt, forHTTPHeaderField: "user_token")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(T.self, from: data)
            return response
        } catch {
            print("error get" + error.localizedDescription)
            return nil
        }
        
    }

    func post(from path: String, json: [String: Any] = [:]) async -> Data? {
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue(jwt, forHTTPHeaderField: "user_token")
        if jsonData != nil {
            request.httpBody = jsonData
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return data
        } catch {
            print(error)
            return nil
        }
    }
}
