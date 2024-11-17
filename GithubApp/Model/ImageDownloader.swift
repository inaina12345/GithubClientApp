//
//  ImageDownloader.swift
//  GithubApp
//
//  Created by mac on 2024/11/17.
//

import Foundation
import UIKit

final class ImageDownloader {
    // UIImageをキャッシュするための変数
    var cacheImage: UIImage?

    func downloadImage(imageURL: String,
                        success: @escaping (UIImage) -> Void,
                        failure: @escaping (Error) -> Void) {
        // もしキャッシュされたUIImageがあれば、それをClosureで返す。
        if let cacheImage = cacheImage {
            success(cacheImage)
        }
        
        // リクエストの作成
        var request = URLRequest(url: URL(string: imageURL)!)
        request.httpMethod = "GET"

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

            // 受け取ったデータからUIImageを作成できないなら、
            // APIError.unknown ErrorをClosureで返す
            guard let imageFromData = UIImage(data: data) else {
                DispatchQueue.main.async {
                    failure(APIError.unknown)
                }
                return
            }

            // imageFromDataをClosureで返す
            DispatchQueue.main.async {
                success(imageFromData)

                // 画像をキャッシュする
                self.cacheImage = imageFromData
            }
        }
        task.resume()
    }
}

/*
 // このImageDownloaderクラスは以下のように使います。

 let imageDownloader = ImageDownloader()
 let imageURL = URL(string: "test") // imageURL

 imageDownloader.downloadImage(imageURL: imageURL,
                               success: { (image) in
                                 // リクエストに成功したら、UIImageが返ってくる
                               }) { (error) in
                                 // リクエストに失敗したら、Errorが返ってくる
                               }
 */
