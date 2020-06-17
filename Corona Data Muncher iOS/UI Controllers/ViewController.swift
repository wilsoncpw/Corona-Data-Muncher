//
//  ViewController.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 16/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import UIKit

protocol MainViewProtocol {
    var dataController: DataController? { get set }
}

class ViewController: UIViewController, MainViewProtocol {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
        
    var dataController: DataController? {
        didSet {
            update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.mainViewController = self
        }
                
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        
//        scrollView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh () {
        let downloader = PHEDataDownloader ()
        downloader.loadDataIntoController { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error) : StatusBarNotify (message: error.localizedDescription).post()
                case .success(let dataController) :
                    self.dataController = dataController
                }
            }
        }

        
        DispatchQueue.main.async {
            self.dataController = nil
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    

    override func viewDidLayoutSubviews() {
        update ()
    }
    private func initLabels () {
        dateLabel.text = "Loading..."
        deathsLabel.text = ""
        casesLabel.text = ""
    }
    
    private func update () {
        guard let data = dataController else {
            initLabels()
            return
        }
        
        dateLabel.text = DateFormatter.localizedString(from: data.deaths.metadata.lastUpdatedAt, dateStyle: .full, timeStyle: UIApplication.shared.isLandscape ? .full : .long)
        deathsLabel.text = "\(data.deaths.overview [0].dailyChangeInDeaths!) new deaths"
        casesLabel.text = "\(data.cases.dailyRecords.dailyLabConfirmedCases) new cases"
        //            deathsViewController?.dataController = dataController
    }
    
}

