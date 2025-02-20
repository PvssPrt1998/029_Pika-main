//
//  HistoryViewController.swift
//  29Pika
//
//  Created by Владимир Кацап on 24.12.2024.
//

import UIKit
import Combine
import GSPlayer

class HistoryViewController: UIViewController {
    
    let model: MainModel
    private lazy var cancellable = [AnyCancellable]()
    
    private let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
        layout.scrollDirection = .vertical
        collection.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        return collection
    }()
    
    private lazy var noArrVideow: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = .clear
        
        let label = UILabel()
        label.text = "You don't have a video yet.\nGenerate a video right now!"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .white
        label.font = .appFont(.BodyRegular)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let genButton = UIButton(type: .system)
        genButton.layer.cornerRadius = 10
        genButton.setTitle(" Generate", for: .normal)
        genButton.backgroundColor = .secondary
        genButton.tintColor = .black
        genButton.setTitleColor(.black, for: .normal)
        genButton.titleLabel?.font = .appFont(.Title2Emphasized)
        genButton.setImage(.magic.resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
        genButton.addTarget(self, action: #selector(goGen), for: .touchUpInside)
        
        view.addSubview(genButton)
        genButton.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).inset(-10)
            make.height.equalTo(48)
            make.width.equalTo(163)
            make.centerX.equalToSuperview()
        }
        
        return view
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
        checkArr()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgMain
        setupUI()
        subscribe()
    }
    
    private func subscribe() {
        model.generatePublisher
            .sink { _ in
                self.checkArr()
            }
            .store(in: &cancellable)
    }

    private func setupNav() {
        let longTitleLabel = UILabel()
        longTitleLabel.text = "You"
        longTitleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        longTitleLabel.textColor = .white
        longTitleLabel.sizeToFit()
        
        let leftItem = UIBarButtonItem(customView: longTitleLabel)
        self.tabBarController?.navigationItem.leftBarButtonItem = leftItem
    }
    
    private func setupUI() {
        
        view.addSubview(noArrVideow)
        noArrVideow.snp.makeConstraints { make in
            make.height.equalTo(110)
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        collection.delegate = self
        collection.dataSource = self
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        
    }
    
    
    private func checkArr() {
        if model.generatedHistoryArr.count > 0 {
            collection.alpha = 1
            noArrVideow.alpha = 0
            collection.reloadData()
        } else {
            noArrVideow.alpha = 1
            collection.alpha = 0
        }
    }
    
    @objc private func goGen() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
        }
    }
    
    @objc private func openVideo(id: String) {
        if let item = model.generatedHistoryArr.first(where: {$0.generateID == id}) {
            let vc = OpenedVideoViewController(model: model, item: item)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func openErrorAlert(id: UUID) {
        let alert = UIAlertController(title: "Error", message: "Video generation error", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Close", style: .cancel)
        alert.addAction(okAction)
        
        let delAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _  in
            self?.delete(id: id)
        }
        alert.addAction(delAction)
        
        self.present(alert, animated: true)
    }
    
    private func delete(id: UUID) {
        if let item = model.generatedHistoryArr.firstIndex(where: {$0.id == id}){
            model.generatedHistoryArr.remove(at: item)
            model.saveHistoryArr()
            collection.reloadData()
        }
    }

}


extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.generatedHistoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.backgroundColor = .bgLight
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true
        
        let item = model.generatedHistoryArr.reversed()[indexPath.row]
        
        let imageViewBlur = UIImageView(image: UIImage(data: item.imageOne ?? Data()))
        imageViewBlur.contentMode = .scaleAspectFill
        cell.addSubview(imageViewBlur)
        imageViewBlur.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        imageViewBlur.addSubview(blurEffectView)

        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        cell.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activityIndicator.startAnimating()
        
        if item.status == "error" {
            cell.layer.borderColor = UIColor.systemRed.cgColor
            cell.layer.borderWidth = 2
            activityIndicator.stopAnimating()
            
            let label = UILabel()
            label.text = "Error generate video"
            label.textColor = .systemRed
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = .appFont(.BodyRegular)
            cell.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.left.right.equalToSuperview().inset(10)
            }
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
        }
        
        
        let videoPlayer = VideoPlayerView()
        videoPlayer.playerLayer.videoGravity = .resizeAspectFill
        if let url = URL(string: item.videoUrl ?? "") {
            videoPlayer.play(for: url)
            videoPlayer.isMuted = true
        }
        cell.addSubview(videoPlayer)
        videoPlayer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        let smallShaow = UIImageView(image: .smallShadow)
        smallShaow.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.addSubview(smallShaow)
        smallShaow.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(-5)
            make.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        
        let label = UILabel()
        label.text = item.nameEffect
        label.textColor = .white
        label.font = .appFont(.BodyRegular)
        label.textAlignment = .right
        cell.addSubview(label)
        label.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(5)
            make.left.equalTo(cell.snp.centerX).offset(5)
        }
        
        let imaegViewVolt = UIImageView(image: .volt)
        cell.addSubview(imaegViewVolt)
        imaegViewVolt.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(16)
            make.right.equalTo(cell.snp.centerX)
            make.centerY.equalTo(label)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 175, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = model.generatedHistoryArr.reversed()[indexPath.row]
        if (item.videoUrl != nil && item.videoUrl != "noVideo") && item.status != "error" {
            openVideo(id: item.generateID ?? "")
        } else {
            openErrorAlert(id: item.id)
        }
    }
    
    
}
