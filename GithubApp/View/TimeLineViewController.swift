//
//  TimeLineViewController.swift
//  GithubApp
//
//  Created by mac on 2024/11/17.
//

import Foundation
import UIKit
import SafariServices

final class TimeLineViewController: UIViewController {
    private var viewModel: UserListViewModel!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView を生成
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TimeLineCell.nib, forCellReuseIdentifier: TimeLineCell.identifier)
        view.addSubview(tableView)

        // 更新し、UIRefreshControl を設定し、リフレッシュした時に呼ばれるメソッドを設定
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged(sender: )), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // UserListViewModel を生成し、通知を受け取った時の処理を監視している
        viewModel = UserListViewModel()
        viewModel.stateDidUpdate = { [weak self] state in
            switch state {
            case .loading:
                // 通信中だったら、tableViewを操作不能にしている
                self?.tableView.isUserInteractionEnabled = false
                break
            case .finish:
                // 通信が完了したら、tableViewを操作可能にし、tableViewを更新
                // また、refreshControl.endRefreshing を呼んでいる
                self?.tableView.isUserInteractionEnabled = true
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                break
            case .error(let error):
                // エラーだった場合、tableViewを操作可能にする
                // また、refreshControl.endRefreshingを呼んでいる
                self?.tableView.isUserInteractionEnabled = true
                self?.refreshControl.endRefreshing()
                
                let alertController = UIAlertController(title: nil,
                                                        message: error.localizedDescription,
                                                        preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "OK",
                                                style: .cancel,
                                                handler: nil)
                alertController.addAction(alertAction)
                self?.present(alertController, animated: true, completion: nil)
                break
            }
        }
        // ユーザー一覧を取得している
        viewModel.getUsers()
    }
    
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        // リフレッシュした時、ユーザー一覧を取得している
        viewModel.getUsers()
    }
}

extension TimeLineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    // viewModel.usersCount() を tableView の Cell の数として設定している
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.usersCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let timelineCell = tableView.dequeueReusableCell(withIdentifier: TimeLineCell.identifier) as? TimeLineCell {
            //その Cell の UserCellViewModel を取得し、timelineCell に対して、nickName と、icon をセットしている
            let cellViewModel = viewModel.cellViewModels[indexPath.row]
            timelineCell.setNickName(nickName: cellViewModel.nickName)

            cellViewModel.downloadImage { (progress) in
                switch progress {
                case .loading(let image):
                    timelineCell.setIcon(icon: image)
                    break
                case .finish(let image):
                    timelineCell.setIcon(icon: image)
                    break
                case .error:
                    break
                }
            }
            return timelineCell
        }
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        /*
         その Cell の UserCellViewModel を取得し、そのユーザーの GitHub ページ
         画面遷移している
         */

        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        guard let webURL = cellViewModel.webURL else { return }

        let webViewController = SFSafariViewController(url: webURL)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
}
