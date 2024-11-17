//
//  TimeLineCell.swift
//  GithubApp
//
//  Created by mac on 2024/11/17.
//

import Foundation
import UIKit

class TimeLineCell: UITableViewCell {
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
  
    // ユーザーのアイコンを表示するための UIImageView
    @IBOutlet private var iconView: UIImageView!
    // ユーザーのnickNameを表示するためのUILabel
    @IBOutlet private var nickNameLabel: UILabel!
    
    // ユーザーのnickNameをセット
    func setNickName(nickName: String) {
        guard let _ = nickNameLabel else {
            return
        }
        nickNameLabel.text = nickName
    }

    // ユーザーのアイコンをセット
    func setIcon(icon: UIImage) {
        guard let _ = iconView else {
            return
        }
        iconView.image = icon
    }
}
