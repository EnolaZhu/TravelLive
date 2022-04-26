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
        EventCollectionViewController(),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        

    }

    func setupTableView() {
        let nib = UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil)

        eventTableView.register(nib, forCellReuseIdentifier: String(describing: EventTableViewCell.self))

        eventTableView.dataSource = self

        eventTableView.delegate = self

        eventTableView.backgroundColor = UIColor.orange
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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





























//extension EventViewController {
//
//    func getPlaceData(city: Int, limit: Int) {
//
//        MapDataProvider.shared.fetchSpecificPlaceInfo(city: city, limit: limit)  { [weak self] result in
//            switch result {
//            case .success(let data):
//                self?.specificPlaceData = data
//                guard let specificPlaceData = self?.specificPlaceData else { return }
//
//                if specificPlaceData.data.count > 0 {
//                    guard let specificPlaceData = self?.specificPlaceData else { return }
//                    for index in 0...specificPlaceData.data.count - 1 {
//                        ImageManager.shared.fetchImage(imageUrl: specificPlaceData.data[index].image) { image in
//                            print("success")
//                        }
//                    }
//                }
//
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//
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
//                        ImageManager.shared.fetchImage(imageUrl: specificEventData.data[index].image) { image in
//                            print("success")
//                        }
//                    }
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//}
