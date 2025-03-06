import UIKit
import Combine
import GSPlayer

class PreviewV2ViewController: UIViewController {
    
    let model: MainModel
    let item: Effect
    //let genTappedPublisher: PassthroughSubject<Effect,Never>
    private var player: VideoPlayerView?
    
    init(model: MainModel, effect: Effect) { //genTappedPublisher: PassthroughSubject<Effect,Never>/
        self.model = model
        self.item = effect
        //self.genTappedPublisher = genTappedPublisher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgMain
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = item.effect
    }
    
    private func setupUI() {
        let useButton = UIButton(type: .system)
        useButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        useButton.setImage(.moln.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
        useButton.tintColor = .black
        useButton.setTitle("Use the effect", for: .normal)
        useButton.setTitleColor(.black, for: .normal)
        useButton.titleLabel?.font = .appFont(.Title2Emphasized)
        useButton.layer.cornerRadius = 8
        useButton.backgroundColor = .secondary
        view.addSubview(useButton)
        useButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
            make.height.equalTo(48)
            //make.right.equalTo(likeButton.snp.left).inset(-10)
        }
        
        player = VideoPlayerView()
        player?.layer.cornerRadius = 8
        player?.clipsToBounds = true
        player?.playerLayer.videoGravity = .resizeAspectFill
        
        if let localUrl = item.localUrl, let url = URL(string: localUrl) {
            player?.play(for: url)
            //print("LOCAL LOADED")
            player?.isMuted = true
        } else {
            if let urlStr = item.previewSmall, let url = URL(string: urlStr) {
                player?.play(for: url)
                player?.isMuted = true
            }
        }
//        if let url = Bundle.main.url(forResource: item.previewSmall ?? "", withExtension: "mp4") {
//            player?.play(for: url)
//            player?.isMuted = true
//        }
//        if let urlStr = item.previewSmall, let url = URL(string: urlStr) {
//            player?.play(for: url)
//            player?.isMuted = true
//        }
        
        view.addSubview(player ?? UIView())
        player?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
            make.bottom.equalTo(useButton.snp.top).inset(-15)
        })
    }
    
    @objc private func nextTapped() {
        if model.purchaseManager.hasUnlockedPro {
            if model.tokens < 1 {
                openLimitAlert()
            } else {
                if model.timers.count >= 2 {
                    openLimitAlert()
                } else {
                    //genTappedPublisher.send(item)
                    let vc = LoadImaeViewController(effect: item, model: model)
                    self.navigationController?.pushViewController(vc, animated: true)
                    //close()
                }
            }
            
        } else {
            openPaywall()
        }
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
    private func openTokensAlert() {
        
        let alert = UIAlertController(title: "You have less than 10 tokens", message: "Not enough tokens to generate", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {
                UIAlertAction in
            let tokensPaywallViewController = TokensPaywallViewController(model: self.model)
            tokensPaywallViewController.modalPresentationStyle = .fullScreen
            tokensPaywallViewController.modalTransitionStyle = .coverVertical
            if #available(iOS 13.0, *) {
                tokensPaywallViewController.isModalInPresentation = true
            }
            self.present(tokensPaywallViewController, animated: true)
                NSLog("OK Pressed")
        }
        let ok = UIAlertAction(title: "Got it", style: .cancel)
        
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
