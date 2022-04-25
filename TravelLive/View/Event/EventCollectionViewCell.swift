//
//  EventCollectionViewCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

//import UIKit
//
//private enum State {
//    case expanded
//    case collapsed
//
//    var change: State {
//        switch self {
//        case .expanded: return .collapsed
//        case .collapsed: return .expanded
//        }
//    }
//}
//
//class EventCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
//
//    private let cornerRadius: CGFloat = 6
//
//    static let cellSize = CGSize(width: 250, height: 350)
//    static let identifier = "EventCollectionCell"
//
//    @IBOutlet weak var closeButton: UIButton!
//    @IBOutlet weak var eventImage: UIImageView!
//    @IBOutlet weak var eventTitleLabel: UILabel!
//
//    @IBOutlet weak var descriptionLabel: UILabel!
//    private var collectionView: UICollectionView?
//    private var index: Int?
//
//    private var initialFrame: CGRect?
//    private var state: State = .collapsed
//    private lazy var animator: UIViewPropertyAnimator = {
//        return UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
//    }()
//
//    private let popupOffset: CGFloat = (UIScreen.height - cellSize.height)/2.0
//    private lazy var panRecognizer: UIPanGestureRecognizer = {
//        let recognizer = UIPanGestureRecognizer()
//        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
//        recognizer.delegate = self
//        return recognizer
//    }()
//
//    private var animationProgress: CGFloat = 0
//
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return abs((panRecognizer.velocity(in: panRecognizer.view)).y) > abs((panRecognizer.velocity(in: panRecognizer.view)).x)
//    }
//
//
//    override func awakeFromNib() {
//        descriptionLabel.isHidden = true
//        self.addGestureRecognizer(panRecognizer)
//    }
//
//    @objc func popupViewPanned(recognizer: UIPanGestureRecognizer) {
//
//        switch recognizer.state {
//        case .began:
//            animationProgress = animator.fractionComplete
//            toggle()
//            animator.pauseAnimation()
//
//        case .changed:
//            let translation = recognizer.translation(in: collectionView)
//            var fraction = -translation.y / popupOffset
//            if state == .expanded { fraction *= -1 }
//            animator.fractionComplete = fraction
//            animator.fractionComplete = fraction + animationProgress
//            if animator.isReversed { fraction *= -1 }
//
//        case .ended:
//            let velocity = recognizer.velocity(in: self)
//            let shouldComplete = velocity.y > 0
//
//            if velocity.y == 0 {
//                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
//                break
//            }
//
//            switch state {
//            case .expanded:
//                if !shouldComplete && !animator.isReversed { animator.isReversed = !animator.isReversed }
//                if shouldComplete && animator.isReversed { animator.isReversed = !animator.isReversed }
//            case .collapsed:
//                if shouldComplete && !animator.isReversed { animator.isReversed = !animator.isReversed }
//                if !shouldComplete && animator.isReversed { animator.isReversed = !animator.isReversed }
//            }
//            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
//
//        default:
//            ()
//        }
//    }
//
//    func configure(with event: Event, collectionView: UICollectionView, index: Int) {
//        eventTitleLabel.text = event.name
//        eventImage.image = UIImage(named: event.image)
//        descriptionLabel.text = event.description
//
//        self.collectionView = collectionView
//        self.index = index
//    }
//
//    @IBAction func close(_ sender: Any) {
//        toggle()
//    }
//
//    func toggle() {
//        switch state {
//        case .expanded:
//            collapse()
//        case .collapsed:
//            expand()
//        }
//    }
//
//    private func expand() {
//        guard let collectionView = self.collectionView, let index = self.index else { return }
//
//        animator.addAnimations {
//            self.initialFrame = self.frame
//            self.descriptionLabel.textColor = UIColor.black
//            self.descriptionLabel.alpha = 1
//            self.descriptionLabel.isHidden = false
//            self.closeButton.alpha = 1
//
//            self.layer.cornerRadius = 0
//            self.frame = CGRect(x: collectionView.contentOffset.x, y: 0, width: UIScreen.width, height: 600)
//
//            if let leftCell = collectionView.cellForItem(at: IndexPath(row: index - 1, section: 0)) {
//                leftCell.center.x -= 50
//            }
//
//            if let rightCell = collectionView.cellForItem(at: IndexPath(row: index + 1, section: 0)) {
//                rightCell.center.x += 50
//            }
//
//            self.layoutIfNeeded()
//        }
//
//        animator.addCompletion { position in
//            switch position {
//            case .end:
//                self.state = self.state.change
//                collectionView.isScrollEnabled = false
//                collectionView.allowsSelection = false
//            default:
//                ()
//            }
//        }
//
//        animator.startAnimation()
//    }
//
//    private func collapse() {
//        guard let collectionView = self.collectionView, let index = self.index else { return }
//
//        animator.addAnimations {
//            self.descriptionLabel.isHidden = true
//            self.descriptionLabel.alpha = 0
//            self.closeButton.alpha = 0
//
//            self.layer.cornerRadius = self.cornerRadius
//            self.frame = self.initialFrame!
//
//            if let leftCell = collectionView.cellForItem(at: IndexPath(row: index - 1, section: 0)) {
//                leftCell.center.x += 50
//            }
//
//            if let rightCell = collectionView.cellForItem(at: IndexPath(row: index + 1, section: 0)) {
//                rightCell.center.x -= 50
//            }
//
//            self.layoutIfNeeded()
//        }
//
//        animator.addCompletion { position in
//            switch position {
//            case .end:
//                self.state = self.state.change
//                collectionView.isScrollEnabled = true
//                collectionView.allowsSelection = true
//            default:
//                ()
//            }
//        }
//
//        animator.startAnimation()
//    }
//}
