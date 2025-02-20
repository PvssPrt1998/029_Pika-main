//
//  GenerateViewController.swift
//  29Pika
//
//  Created by Владимир Кацап on 24.12.2024.
//

import UIKit
import Combine

class GenerateViewController: UIViewController {
    
    private lazy var cancellable = [AnyCancellable]()
    
    let model: MainModel
    var idGen: String = ""
    let imageBlur: UIImage
    let effect: Effect
    
    init(model: MainModel, imageBlur: UIImage, effect: Effect) {
        self.model = model
        self.imageBlur = imageBlur
        self.effect = effect
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav()
    }
    
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let prog = UIActivityIndicatorView(style: .large)
        prog.color = .secondary
        view.addSubview(prog)
        prog.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        prog.startAnimating()
        
        let label = UILabel()
        label.text = "Generation"
        label.textColor = .secondary
        label.font = .appFont(.BodyRegular)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(prog)
            make.left.equalTo(prog.snp.right).inset(-10)
        }

        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgMain
        subscribe()
        createUI()
        send()
    }
    
    private func send() {
        model.createGenerate(image: imageBlur.jpegData(compressionQuality: 0.5) ?? Data(), idEffect: effect.id, nameEffect: effect.effect) { idGen in
            if idGen != "error" {
                self.idGen = idGen
                self.model.checkStatus()
            } else {
                self.showErrorAlert()
            }
        }
    }
    
    private func subscribe() {
        model.generatePublisher
            .sink { idGem in
                if idGem == self.idGen {
                    self.equalId()
                }
            }
            .store(in: &cancellable)
    }
    
    private func equalId() {
        if let item = model.generatedHistoryArr.first(where: {$0.generateID  == idGen }) {
            if item.status == "error" || item.videoUrl == "noVideo" {
                self.showErrorAlert()
            } else if item.videoUrl != "error" && item.videoUrl != nil {
                let vc = OpenedVideoViewController(model: model, item: item)
                vc.isGen = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func setupNav() {
        self.title = "Generate"
        
        let backBut = UIButton(type: .system)
        backBut.setBackgroundImage(.backButt, for: .normal)
        backBut.addTarget(self, action: #selector(backToRoot), for: .touchUpInside)
        
        let backButton = UIBarButtonItem(customView: backBut)
        navigationItem.leftBarButtonItem = backButton
        
        backBut.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.width.equalTo(62)
        }
    }
    
    private func createUI() {
        let imageView = UIImageView(image: imageBlur)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        imageView.addSubview(blurEffectView)

        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.height.equalTo(40)
            make.width.equalTo(140)
        }
    }
    
    @objc private func backToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    


    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Video generation error",
            message: "Something went wrong or the server is not responding. Try again or do it later.",
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.close()
        }
        alert.addAction(cancel)
        
        let again = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.send()
        }
        alert.addAction(again)
        
        self.present(alert, animated: true)
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }

}
