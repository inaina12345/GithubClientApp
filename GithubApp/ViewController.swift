//
//  ViewController.swift
//  GithubApp
//
//  Created by mac on 2024/11/17.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view.        
        present(TimeLineViewController(), animated: true)
    }


}

