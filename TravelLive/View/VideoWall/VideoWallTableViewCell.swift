//
//  VideoWallTableViewCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/11.
//

import UIKit
import AVFoundation

class VideoWallTableViewCell: UITableViewCell, ASAutoPlayVideoLayerContainer {
    var playerController: ASVideoPlayerController?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                ASVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var videoWallImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpComponents()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setUpComponents() {
        setUpButtonBasicColor(blockButton, UIImage.asset(.block)!, color: UIColor.white)
        nameLabel.textColor = UIColor.white
        
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        
        videoWallImageView.backgroundColor = UIColor.black
        videoWallImageView.clipsToBounds = true
        videoWallImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        videoWallImageView.layer.borderWidth = 0.5
        videoWallImageView.contentMode = .scaleAspectFit
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        videoWallImageView.layer.addSublayer(videoLayer)
    }
    
    func configureCell(imageUrl: String?, videoUrl: String?, name: String) {
        videoWallImageView.imageURL = imageUrl
        videoURL = videoUrl
        nameLabel.text = name
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        videoWallImageView.imageURL = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        videoLayer.frame = videoWallImageView.bounds
    }
    
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(videoWallImageView.frame, from: videoWallImageView)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
             return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
}
