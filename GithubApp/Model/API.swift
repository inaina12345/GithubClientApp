//
//  API.swift
//  GithubApp
//
//  Created by mac on 2024/11/17.
//

import Foundation

enum APIError: Error, CustomStringConvertible {
    case unknown
    case invalidURL
    case invalidResponse

    var description: String {
        switch self {
        case .unknown: return "不明なエラーです"
        case .invalidURL: return "無効なURLです"
        case .invalidResponse: return "フォーマットが無効なレスポンスを受け取りました"
        }
    }
}

class API {
    func getUsers(success: @escaping ([User]) -> Void,
                  failure: @escaping (Error) -> Void) {
        let requestURL = URL(string: "https://api.github.com/users")
        guard let url = requestURL else {
            failure(APIError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Errorがあったら、ErrorをClosureで返す
            if let error = error {
                DispatchQueue.main.async {
                    failure(error)
                }
                return
            }

            // dataがなかったら、APIError.unknown ErrorをClosureで返す
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(APIError.unknown)
                }
                return
            }

            // レスポンスのデータ型が不正だったら、APIError.invalidResponse ErrorをClosureで返す
            guard let jsonOptional = try? JSONSerialization.jsonObject(with: data, options: []),
                  let json = jsonOptional as? [[String: Any]] else {
                DispatchQueue.main.async { 
                    failure(APIError.invalidResponse)
                }
                return
            }
            
            /*
            jsonからUserを作成し、[User]に追加し、
            [User]をClosureで返す
            */
            var users = [User]()
            json.forEach {
                users.append(User(attributes: $0))
            }

            DispatchQueue.main.async {
                success(users)
            }

        }
        task.resume()
        
        
    }
}

/*
 APIクラスの使い方
 
 let api = API()
 api.getUsers(success: { (users) in
     // リクエストに成功したら、[User] が返ってくる
 }) { (error) in
     // リクエストに失敗したら、Error が返ってくる
 }
 */
