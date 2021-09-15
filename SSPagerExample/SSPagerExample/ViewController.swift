//
//  ViewController.swift
//  SSPagerExample
//
//  Created by Eido Goya on 2021/09/15.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var BasicButton: UIButton!
    @IBOutlet weak var CenteredButton: UIButton!
    @IBOutlet weak var BannerButton: UIButton!
    @IBOutlet weak var BasicRxButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func basicButtonClicked(_ sender: UIButton) {
        let vc = BasicViewController()
        vc.view.backgroundColor = .white
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func centeredButtonClicked(_ sender: UIButton) {
        let vc = CenteredViewController()
        vc.view.backgroundColor = .white
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func bannerButtonClicked(_ sender: UIButton) {
        let vc = BannerViewController()
        vc.view.backgroundColor = .white
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func basicRxButtonClicked(_ sender: UIButton) {
        let vc = RxBasicViewController()
        vc.view.backgroundColor = .white
        navigationController?.pushViewController(vc, animated: true)
    }
}
