//
//  UserCellViewModel.swift
//  GithubApp
//
//  Created by mac on 2024/11/17.
//

// UserCellViewModelは、Cell一つ一つに対するアウトプットを担当します。具体的には以下のような役割を担っています。
// ・ImageDownloaderから、そのユーザーのiconをダウンロードする
// ・ImageDownloaderから、ダウンロード中か、エラーの状態を持ち、通知を送る。
// ・Imageをダウンロード中、グレーのImageをアウトプットする。成功した時は、そのUIImageをアウトプットする。
// ・Cellの見た目にも反映させるアウトプットをする

// UserCellViewModelの定義は以下のコードです。

import Foundation
import UIKit

enum ImageDownloadProgress {
    case loading(UIImage)
    case finish(UIImage)
    case error
}

final class UserCellViewModel {
    // ユーザーを変数として保持
    private var user: User

    // ImageDownloaderを変数として保持
    private let imageDownloader = ImageDownloader()

    // ImageDownloaderでダウンロード中かどうかをBool変数として保持
    private var isLoading = false

    // Cellに反映させるアウトプット
    var nickName: String {
        return user.name
    }

    // Cellを選択した時に必要なwebURL
    var webURL: URL? {
        return URL(string: user.webURL)
    }

    // userを引数にinit
    init(user: User) {
        self.user = user
    }
    
    func downloadImage(progress: @escaping (ImageDownloadProgress) -> Void) {
        if isLoading == true {
            return // すでにダウンロード中だったら、何もせずreturn。このメソッドはcellForRowメソッドで呼ばれることを想定しているため、何度もダウンロードしないためにisLoadingを使用している
        }

        isLoading = true

        // grayのUIImageを作成
        let loadingImage = UIImage(color: .gray, size: CGSize(width: 45, height: 45))!

        // LoadingをClosureで渡している
        progress(.loading(loadingImage))

        // imageDownloaderを使用して、画像をダウンロードしている。
        // 引数に、user.iconUrlを使っている
        // ダウンロードが終了したら、finishをClosureで渡している
        // Errorだったら、errorをClosureで渡している
        imageDownloader.downloadImage(imageURL: user.iconUrl,
                                       success: { (image) in
                                           progress(.finish(image))
                                           self.isLoading = false
                                       }) { (error) in
                                           progress(.error)
                                           self.isLoading = false
                                       }
    }
}


extension UIImage {
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
