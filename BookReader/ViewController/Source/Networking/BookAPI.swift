//
//  BookAPI.swift
//  BookReader
//
//  Created by hung on 30/05/2021.
//

import Foundation

class BookAPI {
    let base = "http://192.168.1.105:8080"
    static let shared = BookAPI()
}

extension BookAPI {
    
    func getAllBooks(_ completion: @escaping ([Book]) -> ()){
        let path = base + "/books?page=0&size=40"
        
        get(from: path, type: Content.self) { (result) in
            if case .success(let response) = result {
                completion(response.content ?? [])
            }
        }
    }
    
    func getBookById(id: String, _ completion: @escaping (Book) -> ()) {
        let path = base + "/books/\(id)"
        
        get(from: path, type: Book.self) { (result) in
            if case .success(let response) = result {
                completion(response)
            }
        }
    }
    
    func getLikedBooks(_ completion: @escaping ([Book]) -> ()){
        let path = base + "/books/likes"

        get(from: path, type: FavoriteBooks.self) { (result) in
            if case .success(let response) = result {
                completion(response.favoriteBooks ?? [])
            }
        }
    }
    
    func getBooksByKeyword(_ keyword: String, _ completion: @escaping ([Book]) -> ()) {
        let path = base + "/books?page=0&name=\(keyword)"
            .addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        
        get(from: path, type: Content.self) { (result) in
            if case .success(let response) = result {
                completion(response.content ?? [])
            }
        }
    }
    
    func getBooksByCategory(categoryId: Int, _ completion: @escaping ([Book]) -> ()) {
        let path = base + "/categories/\(categoryId)"
        
        get(from: path, type: Category.self) { (result) in
            if case .success(let response) = result {
                completion(response.books ?? [])
            }
        }
        
    }
    
    func getReviews(bookId: String, _ completion: @escaping ([Review]) -> ()) {
        let path = base + "/books/\(bookId)/reviews"
        
        get(from: path, type: ListReviews.self) { (result) in
            if case .success(let response) = result {
                completion(response.reviews)
            }
        }
        
    }
    
    func getRating(id: String, _ completion: @escaping (Float) -> ()) {
        let path = base + "/books/\(id)/rateAverage"

        get(from: path, type: Float.self) { (result) in
            if case .success(let response) = result {
                completion(response)
            }
        }
    }
    
    func postLike(id: String, _ completion: @escaping (Data) -> ()) {
        let path = base + "/books/\(id)/likes"
        
        post(from: path) { (data) in
            completion(data)
        }
    }
    
    func postReview(bookId: String, _ comment: String, _ rate: Float, _ completion: @escaping (Data) -> ()) {
        let path = base + "/books/\(bookId)/reviews"
        let json: [String: Any] = ["content": "\(comment)", "rate": rate]
        
        post(from: path, json: json) { (data) in
            completion(data)
        }
    }
    
    func getJWT(_ accessToken: String, _ completion: @escaping (String) -> ()) {
        let path = base + "/users"
        let json: [String: Any] = ["accessToken": "\(accessToken)"]
        
        post(from: path, json: json) { (data) in
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let response = responseJSON as? [String: Any] {
                    jwt = response["jwt"] as! String
                    completion(jwt)
            }
        }
    }
    
    
    func get<T: Decodable>(from path: String, type: T.Type , result: @escaping (Result<T, Error>) -> Void) {
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        request.setValue(jwt, forHTTPHeaderField: "user_token")
        URLSession.shared.dataTask(with: request) { (data, response, taskError) in
            guard let data = data, taskError == nil else {
                print("task error" + taskError!.localizedDescription)
                return result(.failure(taskError!))
            }
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                result(.success(object))
            } catch {
                print("decoder error \(error.localizedDescription)")
                result(.failure(error))
            }
        }.resume()
    }
    
    func post(from path: String, json: [String: Any] = [:], completionHandler: @escaping (Data) -> Void) {
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
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                completionHandler(data)
            }
        }
        task.resume()
    }
}
