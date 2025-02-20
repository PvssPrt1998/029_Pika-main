//
//  PreviewViewController.swift
//  29Pika
//
//  Created by Владимир Кацап on 23.12.2024.
//

import UIKit
import GSPlayer
import Combine

class PreviewViewController: UIViewController {
    
    let model: MainModel
    let item: Effect
    let publisherFavirite: PassthroughSubject<Any,Never>
    let genTappedPublisher: PassthroughSubject<Effect,Never>
    private var player: VideoPlayerView?
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .bgLight
        button.layer.cornerRadius = 10
        return button
    }()
    
    init(model: MainModel, item: Effect, publisherFavirite: PassthroughSubject<Any,Never>, genTappedPublisher: PassthroughSubject<Effect,Never>) {
        self.model = model
        self.item = item
        self.publisherFavirite = publisherFavirite
        self.genTappedPublisher = genTappedPublisher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        setupUI()
    }
    

    private func setupUI() {
        let mainView = UIView()
        mainView.backgroundColor = .bgSecond
        mainView.layer.cornerRadius = 20
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(500)
        }
        
        let nameEffectLabel = UILabel()
        nameEffectLabel.text = item.effect
        nameEffectLabel.textColor = .white
        nameEffectLabel.font = .appFont(.Title2Regular)
        mainView.addSubview(nameEffectLabel)
        nameEffectLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(15)
        }
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(.closePaywall.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = .white
        mainView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.right.top.equalToSuperview().inset(15)
        }
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        mainView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(mainView)
        }
        activityIndicator.startAnimating()
        
        mainView.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(15)
            make.height.width.equalTo(48)
        }
        
        likeButton.setImage(isLike() ? .like.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 32, height: 32)) : .dislike.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
        likeButton.tintColor = isLike() ? .systemRed : .white
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        
        let useButton = UIButton(type: .system)
        useButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        useButton.setImage(.moln.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
        useButton.tintColor = .black
        useButton.setTitle("Use the effect", for: .normal)
        useButton.setTitleColor(.black, for: .normal)
        useButton.titleLabel?.font = .appFont(.Title2Emphasized)
        useButton.layer.cornerRadius = 8
        useButton.backgroundColor = .secondary
        mainView.addSubview(useButton)
        useButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.right.equalTo(likeButton.snp.left).inset(-10)
        }
        
        player = VideoPlayerView()
        player?.layer.cornerRadius = 10
        player?.clipsToBounds = true
        player?.playerLayer.videoGravity = .resizeAspectFill
        if let url = URL(string: item.previewSmall ?? "") {
            player?.play(for: url)
            player?.isMuted = true
        }
        
        mainView.addSubview(player ?? UIView())
        player?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(closeButton.snp.bottom).inset(-15)
            make.bottom.equalTo(useButton.snp.top).inset(-15)
        })
    }
    
    @objc private func nextTapped() {
        if model.purchaseManager.hasUnlockedPro {
            if model.timers.count >= 2 {
                openLimitAlert()
            } else {
                genTappedPublisher.send(item)
                close()
            }
        } else {
            openPaywall()
        }
    }
    
    @objc private func close() {
        self.dismiss(animated: true) { [weak self] in
            self?.player = nil
        }
    }
    
    private func isLike() -> Bool {
        if model.favoriteArrID.contains(where: {$0 == item.id}) {
            return true
        } else {
            return false
        }
    }
    
    @objc private func likeTapped() {
        if isLike() {
            if let index = model.favoriteArrID.firstIndex(where: {$0 == item.id}) {
                model.favoriteArrID.remove(at: index)
                likeButton.setImage( .dislike.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
            }
        } else {
            model.favoriteArrID.append(item.id)
            likeButton.setImage( .like.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
        }
        likeButton.tintColor = isLike() ? .systemRed : .white
        model.saveFavoritesArr()
        publisherFavirite.send(1)
    }
    
    @objc func openPaywall() {
        let paywallViewController = PaywallViewController(model: model)
        paywallViewController.modalPresentationStyle = .fullScreen
        paywallViewController.modalTransitionStyle = .coverVertical
        if #available(iOS 13.0, *) {
            paywallViewController.isModalInPresentation = true
        }
        self.present(paywallViewController, animated: true)
    }
    
    private func openLimitAlert() {
        let alert = UIAlertController(title: "You have reached the simultaneous generation limit ", message: "You cannot generate more than 2 videos at the same time", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Got it", style: .cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
}
