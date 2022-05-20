//
//  EventViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

import UIKit
import Lottie

class EventViewController: UIViewController {
    
    @IBOutlet weak var eventTableView: UITableView!
    
    var smallCollectionViewControllers = [
        EventCollectionViewController(),
        EventCollectionViewController(),
        EventCollectionViewController(),
        EventCollectionViewController(),
        EventCollectionViewController()
    ]
    var citys = ["臺北": 0, "新北": 1, "臺中": 3, "臺南": 4, "高雄": 5]
    let animationView = AnimationView(name: LottieAnimation.lodingAnimation.title)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LottieAnimationManager.shared.showLoadingAnimation(animationView: animationView, view: self.view, name: LottieAnimation.lodingAnimation.title)
        
        setupTableView()
        getData()
        eventTableView.showsVerticalScrollIndicator = false
        eventTableView.backgroundColor = UIColor.backgroundColor
        view.backgroundColor = UIColor.backgroundColor
        
        navigationItem.title = "景點"
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.backgroundColor = .backgroundColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.eventTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil)
        
        eventTableView.register(nib, forCellReuseIdentifier: String(describing: EventTableViewCell.self))
        eventTableView.dataSource = self
        eventTableView.delegate = self
        
        eventTableView.backgroundColor = UIColor.backgroundColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setStatusBar(backgroundColor: UIColor.backgroundColor)
        navigationController?.navigationBar.setNeedsLayout()
    }
    
    private func getData() {
        getPlaceData(city: citys["臺北"] ?? 0, limit: 5)
        getPlaceData(city: citys["新北"] ?? 0, limit: 5)
        getPlaceData(city: citys["臺中"] ?? 0, limit: 5)
        getPlaceData(city: citys["臺南"] ?? 0, limit: 5)
        getPlaceData(city: citys["高雄"] ?? 0, limit: 5)
    }
}

extension EventViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return smallCollectionViewControllers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, widthForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let eventTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self)) as? EventTableViewCell else {
            return UITableViewCell()
        }
        
        self.smallCollectionViewControllers[indexPath.section].view.frame = eventTableViewCell.bounds
        
        self.addChild(self.smallCollectionViewControllers[indexPath.section])
        self.smallCollectionViewControllers[indexPath.section].didMove(toParent: self)
        eventTableViewCell.addSubview(smallCollectionViewControllers[indexPath.section].view)
        
        return eventTableViewCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView()
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 60),
            label.heightAnchor.constraint(equalToConstant: 30),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: -10)
        ])
        
        var titles = [String]()
        for (title, _) in Array(citys).sorted(by: {$0.value < $1.value}) {
            titles.append(title)
        }
        label.text = titles[section]
        
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.primary
        label.font = label.font.withSize(18)
        sectionView.addSubview(label)
        
        return sectionView
    }
}

extension EventViewController {
    
    func getPlaceData(city: Int, limit: Int) {
        MapDataProvider.shared.fetchSpecificPlaceInfo(city: city, limit: limit) { [weak self] result in
            switch result {
            case .success(let data):
                
                var theCity = city
                if city > 2 {
                    theCity -= 1
                }
                self?.smallCollectionViewControllers[theCity].specificPlaceData = data
                
                if data.data.count > 0 {
                    for index in 0...data.data.count - 1 {
                        ImageManager.shared.fetchImage(imageUrl: data.data[index].image) { [weak self] image in
                            self?.smallCollectionViewControllers[theCity].images.append(image)
                            self?.eventTableView.reloadData()
                        }
                    }
                    LottieAnimationManager.shared.stopAnimation(animationView: self?.animationView)
                }
                
            case .failure:
                self?.view.makeToast("獲取資料失敗", duration: 1.0, position: .center)
            }
        }
    }
}
