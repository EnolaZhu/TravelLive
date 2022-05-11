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
    

    @IBOutlet weak var videoWallImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        videoWallImageView.layer.cornerRadius = 5
        videoWallImageView.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        videoWallImageView.clipsToBounds = true
        videoWallImageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        videoWallImageView.layer.borderWidth = 0.5
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        videoWallImageView.layer.addSublayer(videoLayer)
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(imageUrl: String?, videoUrl: String?) {
        self.videoWallImageView.imageURL = imageUrl
        self.videoURL = videoUrl
    }

    override func prepareForReuse() {
        videoWallImageView.imageURL = nil
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let horizontalMargin: CGFloat = 20
        let width: CGFloat = bounds.size.width - horizontalMargin * 2
        let height: CGFloat = (width * 0.9).rounded(.up)
        videoLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
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
