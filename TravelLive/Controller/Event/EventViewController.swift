//
//  EventViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

import UIKit

class EventViewController: UIViewController {

    @IBOutlet weak var eventTableView: UITableView!
    
    var smallCollectionViewControllers = [
        EventCollectionViewController(),
        EventCollectionViewController(),
        EventCollectionViewController(),
        EventCollectionViewController(),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        getPlaceData(city: 0, limit: 5)
        getPlaceData(city: 1, limit: 5)
        getPlaceData(city: 2, limit: 5)
        getPlaceData(city: 3, limit: 5)
//        getEventData(city: 4, limit: 20)
        navigationItem.title = "景點"
    }

    func setupTableView() {
        let nib = UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil)

        eventTableView.register(nib, forCellReuseIdentifier: String(describing: EventTableViewCell.self))
        eventTableView.dataSource = self
        eventTableView.delegate = self

        eventTableView.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

extension EventViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return smallCollectionViewControllers.count

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 300
    }
    
// swiftlint:disable force_cast identifier_name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self)) as! EventTableViewCell
        
        
        return eventTableViewCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let eventTableViewCell = cell as! EventTableViewCell

        self.smallCollectionViewControllers[indexPath.row].collectionView.frame = eventTableViewCell.bounds

        self.addChild(self.smallCollectionViewControllers[indexPath.row])
        self.smallCollectionViewControllers[indexPath.row].didMove(toParent: self)
        eventTableViewCell.addSubview(smallCollectionViewControllers[indexPath.row].view)
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
