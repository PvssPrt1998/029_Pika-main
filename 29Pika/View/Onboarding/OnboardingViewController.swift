//
//  OnboardingViewController.swift
//  29Pika
//
//  Created by Владимир Кацап on 12.12.2024.
//

import UIKit
import SnapKit

class OnboardingViewController: UIViewController {
    
    let model: MainModel
    let arr: [Onb] = [Onb(mainText: "Transform Photos with Fun", subText: "Easily apply creative effects to your photos with just a tap", image: .tap1), Onb(mainText: "Unleash Fun Creative Effects", subText: "Squish, explode, crash, and more – unleash your creativity!", image: .tap2), Onb(mainText: "Instant Results, Every Time", subText: "Just choose an effect and watch your photo come to life!", image: .tap3), Onb(mainText: "Rate our app in the AppStore", subText: "Help us grow up, share the app with your friends", image: .tap4), Onb(mainText: "Start creating right now!", subText: "Discover a world of amazing effects. Surprise your friends, surprise yourself", image: .tap5)]
    
    lazy var tap = 0
    
    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.isPagingEnabled = true
        collection.isScrollEnabled  = false
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
        return collection
    }()
    
    let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .secondary
        control.isEnabled = false
        return control
    }()
    
    init(model: MainModel) {
        self.model = model
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
    
    
    private func setupUI() {
        pageControl.numberOfPages = arr.count
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(26)
        }
        
        collection.delegate = self
        collection.dataSource = self
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(pageControl.snp.top).inset(-10)
        }

    }
    
    struct Onb {
        let mainText: String
        let subText: String
        let image: UIImage
    }
    
    private func createNextButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .secondary
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.setTitleColor(.textTernary, for: .normal)
        return button
    }
    
    @objc private func nextPage() {
        tap += 1
        
        if tap == 5 {
            self.navigationController?.setViewControllers([TabBarViewController(model: model)], animated: true)
            return
        }
        
        if tap <= arr.count {
            collection.scrollToItem(at: IndexPath(row: tap, section: 0), at: .centeredHorizontally, animated: true)
            pageControl.currentPage = tap
        } 
    }
    
    @objc private func rate() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id6739883934?action=write-review") else { //как пример - 6737510164
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Unable to open App Store")
        }
    }

}


extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .bgMain
        
        var nextButton = UIButton()
        
        if indexPath.row != 3 {
            nextButton = createNextButton()
            cell.addSubview(nextButton)
            nextButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.bottom.equalToSuperview()
                make.height.equalTo(48)
            }
            nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        } else {
            let laterButton = UIButton(type: .system)
            laterButton.layer.cornerRadius = 10
            laterButton.setTitle("Later", for: .normal)
            laterButton.setTitleColor(.white, for: .normal)
            laterButton.titleLabel?.font = .appFont(.Title2Emphasized)
            laterButton.backgroundColor = .bgLight
            cell.addSubview(laterButton)
            laterButton.snp.makeConstraints { make in
                make.height.equalTo(48)
                make.left.equalToSuperview().inset(15)
                make.bottom.equalToSuperview()
                make.right.equalTo(cell.snp.centerX).offset(-5)
            }
            laterButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
            
            nextButton = createNextButton()
            nextButton.setTitle("Rate!", for: .normal)
            cell.addSubview(nextButton)
            nextButton.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(15)
                make.left.equalTo(cell.snp.centerX).offset(5)
                make.bottom.equalToSuperview()
                make.height.equalTo(48)
            }
            nextButton.addTarget(self, action: #selector(rate), for: .touchUpInside)
            
        }
        
        let subLabel = UILabel()
        subLabel.text = arr[indexPath.row].subText
        subLabel.font = .appFont(.BodyRegular)
        subLabel.textColor = .white.withAlphaComponent(0.3)
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 2
        
        cell.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(nextButton.snp.top).inset(-20)
            make.height.equalTo(44)
        }
        
        let mainLabel = UILabel()
        mainLabel.textAlignment = .center
        mainLabel.numberOfLines = 2
        mainLabel.text = arr[indexPath.row].mainText
        mainLabel.textColor = .white
        mainLabel.font = .appFont(.LargeTitleEmphasized)
        cell.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(subLabel.snp.top).inset(-5)
            make.height.equalTo(82)
        }
        
        let imageView = UIImageView(image: arr[indexPath.row].image)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(mainLabel.snp.top).inset(-5)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    
    
}
