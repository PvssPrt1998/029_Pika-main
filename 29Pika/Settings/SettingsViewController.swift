//
//  SettingsViewController.swift
//  29Pika
//
//  Created by Владимир Кацап on 25.12.2024.
//

import UIKit
import Combine
import StoreKit

class SettingsViewController: UIViewController {
    
    let model: MainModel
    private lazy var cancellable = [AnyCancellable]()
    private let settingsArr: [settings] = [settings(image: .contact, text: "Contact us"), settings(image: .share, text: "Share the app"), settings(image: .rate, text: "Rate the app"), settings(image: .usage, text: "Usage policy"), settings(image: .privacy, text: "Privacy policy")]
    
    private lazy var bgImage = UIImage.noPro
    private lazy var buttonImageView: UIImageView = {
        let imageView = UIImageView(image: bgImage)
        return imageView
    }()
    
    private lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
        layout.scrollDirection = .vertical
        collection.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        collection.backgroundColor = .clear
        layout.minimumLineSpacing = 5
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    private lazy var subButton: UIButton = {
        let button = UIButton()
        button.addTouchFeedback()
        button.addTarget(self, action: #selector(openPaywall), for: .touchUpInside)
        return button
    }()
    
    init(model: MainModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav()
        self.updateButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgMain
        setupUI()
        subscribe()
    }
    
    private func subscribe() {
        model.purchasePublisher
            .sink { _ in
                self.updateButton()
            }
            .store(in: &cancellable)
    }
    
    
    private func setupNav() {
        let longTitleLabel = UILabel()
        longTitleLabel.text = "Settings"
        longTitleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        longTitleLabel.textColor = .white
        longTitleLabel.sizeToFit()
        
        let leftItem = UIBarButtonItem(customView: longTitleLabel)
        self.tabBarController?.navigationItem.leftBarButtonItem = leftItem
    }
    
    private func setupUI() {
        
        view.addSubview(buttonImageView)
        buttonImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(120)
        }
        
        view.addSubview(subButton)
        subButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(120)
        }
        
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.top.equalTo(subButton.snp.bottom)
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
    
    private func updateButton() {
        for i in subButton.subviews {
            i.removeFromSuperview()
        }
        
        if model.purchaseManager.hasUnlockedPro {
            bgImage = .yesPro
            let labelTop = UILabel()
            labelTop.text = "Subscription Is Active"
            labelTop.textColor = .white
            labelTop.textAlignment = .center
            labelTop.font = .appFont(.Title1Regular)
            subButton.addSubview(labelTop)
            labelTop.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(subButton.snp.centerY).offset(-5)
            }
            
            let dateLabel = UILabel()
            dateLabel.textColor = .white
            dateLabel.textAlignment = .center
            dateLabel.font = .appFont(.BodyRegular)
            let text = model.purchaseManager.dateSubscribe()
            dateLabel.text = text
            subButton.addSubview(dateLabel)
            dateLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(subButton.snp.centerY).offset(5)
            }
            
        } else {
            bgImage = .noPro
            let labelTop = UILabel()
            labelTop.text = "You are not subscribed"
            labelTop.textColor = .white
            labelTop.textAlignment = .center
            labelTop.font = .appFont(.Title1Regular)
            subButton.addSubview(labelTop)
            labelTop.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(subButton.snp.centerY).offset(-5)
            }
            
            let proButton = UIButton(type: .system)
            proButton.setBackgroundImage(.proButton, for: .normal)
            proButton.isUserInteractionEnabled = false
            subButton.addSubview(proButton)
            proButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(subButton.snp.centerY).offset(5)
                make.height.equalTo(38)
                make.width.equalTo(98)
            }
        }
        buttonImageView.image = bgImage
        subButton.setNeedsLayout()
        subButton.layoutIfNeeded()
    }
    
    struct settings {
        let image: UIImage
        let text: String
    }
    
    @objc private func contactUs() {
        let webVC = WebViewController()
        webVC.urlString = "https://docs.google.com/forms/d/e/1FAIpQLSd1OW3z5XvJJDVoMzjjMA-yw7BfVx_eW33ZoZpO9_c6i01e6g/viewform?usp=dialog"
        present(webVC, animated: true, completion: nil)
    }
    
    @objc private func shareFriends() {
        guard let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String else {
            return
        }
        let appURL = "https://apps.apple.com/app/id6739883934"
        let shareText = "\(appName)\n\(appURL)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func rateApp() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id6739883934?action=write-review") else { //как пример - 6737510164
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Unable to open App Store")
        }
    }
    
    @objc private func usage() {
        let webVC = WebViewController()
        webVC.urlString = "https://docs.google.com/document/d/13JXlS7pZorpyb5H5V6nCiATAVDWDyenf0wSs3KRGQf4/edit?usp=sharing"
        present(webVC, animated: true, completion: nil)
    }
    
    @objc private func privacy() {
        let webVC = WebViewController()
        webVC.urlString = "https://docs.google.com/document/d/1Bzr1G22pUKtzDY6VxoiaMAHtEqgTSpYbuXhtMZ4I-Cw/edit?usp=sharing"
        present(webVC, animated: true, completion: nil)
    }
    
}

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .bgLight
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        let item = settingsArr[indexPath.row]
        
        let imageView = UIImageView(image: item.image)
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(20)
        }
        
        let label = UILabel()
        label.text = item.text
        label.textColor = .white
        label.font = .appFont(.BodyRegular)
        cell.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageView.snp.right).inset(-10)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 54)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            contactUs()
        case 1:
            shareFriends()
        case 2:
            rateApp()
        case 3:
            usage()
        case 4:
            privacy()
        default:
            print(indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
           if let cell = collectionView.cellForItem(at: indexPath) {
               UIView.animate(withDuration: 0.2) {
                   cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
               }
           }
       }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
}
