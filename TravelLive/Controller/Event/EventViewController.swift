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
    ]
    var citys = ["臺北", "新北", "桃園", "臺中"]
    let animationView = AnimationView(name: "loading")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LottieAnimationManager.shared.showLoadingAnimation(animationView: animationView, view: self.view, name: "loading")
        
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
        getPlaceData(city: citys.firstIndex(of: "臺北") ?? 0, limit: 5)
        getPlaceData(city: citys.firstIndex(of: "新北") ?? 0, limit: 5)
        getPlaceData(city: citys.firstIndex(of: "桃園") ?? 0, limit: 5)
        getPlaceData(city: citys.firstIndex(of: "臺中") ?? 0, limit: 5)
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
    
// swiftlint:disable force_cast identifier_name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self)) as! EventTableViewCell
        
        self.smallCollectionViewControllers[indexPath.section].view.frame = eventTableViewCell.bounds

        self.addChild(self.smallCollectionViewControllers[indexPath.section])
        self.smallCollectionViewControllers[indexPath.section].didMove(toParent: self)
        eventTableViewCell.addSubview(smallCollectionViewControllers[indexPath.section].view)
        
        return eventTableViewCell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView()
        let label = UILabel(frame: CGRect(x: 24, y: -18, width: 60, height: 30))
        
        label.backgroundColor = UIColor.clear
        label.text = citys[section]
        label.textColor = UIColor.primary
        label.font = label.font.withSize(18)
        sectionView.addSubview(label)
        
        return sectionView
        }
}

extension EventViewController {

    func getPlaceData(city: Int, limit: Int) {
        self.smallCollectionViewControllers[city].images.removeAll()
        
        MapDataProvider.shared.fetchSpecificPlaceInfo(city: city, limit: limit)  { [weak self] result in
            switch result {
            case .success(let data):
                self?.smallCollectionViewControllers[city].specificPlaceData = data

                if data.data.count > 0 {
                    for index in 0...data.data.count - 1 {
                        ImageManager.shared.fetchImage(imageUrl: data.data[index].image) { [weak self] image in
                            self?.smallCollectionViewControllers[city].images.append(image)
                            self?.eventTableView.reloadData()
                            print("success")
                        }
                    }
                    LottieAnimationManager.shared.stopAnimation(animationView: self?.animationView)
                }

            case .failure(let error):
                print(error)
            }
        }
    }

//    func getEventData(city: Int, limit: Int) {
//
//        MapDataProvider.shared.fetchSpecificEventInfo(city: city, limit: limit)  { [weak self] result in
//            switch result {
//
//            case .success(let data):
//                self?.specificEventData = data
//                guard let specificEventData = self?.specificEventData else { return }
//
//                if specificEventData.data.count > 0 {
//                    guard let specificEventData = self?.specificEventData else { return }
//                    for index in 0...specificEventData.data.count - 1 {
//                        ImageManager.shared.fetchImage(imageUrl: specificEventData.data[index].image) { [weak self] image in
//                            print("success")
//                        }
//                    }
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
}
