//
//  UserListViewModel.swift
//  GithubApp
//
//  Created by mac on 2024/11/17.
//

import Foundation

enum ViewModelState {
    case loading
    case finish
    case error(Error)
}

final class UserListViewModel {
    // ViewModelState を Closure として property で保持
    // この変数でViewControllerに対して状態遷移を通知する
    var stateDidUpdate: ((ViewModelState) -> Void)?

    // user の配列
    private var users = [User]()

    // UserCellViewModel の配列
    var cellViewModels = [UserCellViewModel]()

    // Model 層で定義したAPIクラスを参照として保持
    let api = API()

    // userの配列を取得する
    func getUsers() {
        // loading 遷移を送る
        stateDidUpdate?(.loading)
        users.removeAll()

        api.getUsers(success: { (users) in
            self.users.append(contentsOf: users)
            // UserCellViewModel の配列を作成
            for user in users {
                let cellViewModel = UserCellViewModel(user: user)
                self.cellViewModels.append(cellViewModel)
                // 通信が完了したので、finish 通知を送る
                self.stateDidUpdate?(.finish)
            }

        }) { (error) in
            // 通信が失敗したので、error 通知を送る
            self.stateDidUpdate?(.error(error))
        }
    }
    
    // tableViewを表示するために必要なアウトプット
    // UserListViewModelはtableView全体に対するアウトプットなので、
    // tableViewのcountに必要なusers.countがアウトプット
    // tableViewCellに対するアウトプットは、UserCellViewModelが担当
    func usersCount() -> Int {
        return users.count
    }
}
