//
//  OpenedVideoViewController.swift
//  29Pika
//
//  Created by Владимир Кацап on 24.12.2024.
//

import UIKit
import GSPlayer
import Photos

class OpenedVideoViewController: UIViewController {
    
    let model: MainModel
    let item: UserHistory
    var isGen = false 
    
    private var player: VideoPlayerView?
    
    private let activity: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .white
        return view
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.play, for: .normal)
        button.tintColor = .white
        button.isUserInteractionEnabled = false
        button.alpha = 0
        return button
    }()
    
    init(model: MainModel, item: UserHistory) {
        self.model = model
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkGenerate()
    }
    
    private func checkGenerate() {
        if isGen == true {
            if let numb = UserDefaults.standard.object(forKey: "Gen") as? Int {
                var a = numb + 1
                if a == 3 || a == 5 || a == 10 {
                    guard let url = URL(string: "itms-apps://itunes.apple.com/app/id6739883934?action=write-review") else { //как пример - 6737510164
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        print("Unable to open App Store")
                    }
                }
            } else {
                UserDefaults.standard.set(1, forKey: "Gen")
            }
        }
    }
    

    private func setupNav() {
        self.title = "Result"
        
        let backBut = UIButton(type: .system)
        backBut.setBackgroundImage(.backButt, for: .normal)
        backBut.addTarget(self, action: #selector(backToRoot), for: .touchUpInside)
        
        let backButton = UIBarButtonItem(customView: backBut)
        navigationItem.leftBarButtonItem = backButton
        
        backBut.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.width.equalTo(62)
        }
        
        let editVideoButton = UIButton(type: .system)
        editVideoButton.setBackgroundImage(.editVideo, for: .normal)
        let leftItem = UIBarButtonItem(customView: editVideoButton)
        navigationItem.rightBarButtonItem = leftItem
        editVideoButton.addTarget(self, action: #selector(menu), for: .touchUpInside)
        
        editVideoButton.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.width.equalTo(24)
        }
        
        
        
    }
    
    @objc private func backToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setupUI() {
        
        let activiry = UIActivityIndicatorView(style: .medium)
        activiry.color = .secondary
        view.addSubview(activiry)
        activiry.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activiry.startAnimating()
        
        player = VideoPlayerView()
        player?.layer.cornerRadius = 10
        player?.clipsToBounds = true
        player?.playerLayer.videoGravity = .resizeAspectFill
        
        view.addSubview(player ?? UIView())
        player?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
        })
        
        if let url = URL(string: item.videoUrl ?? "") {
            player?.play(for: url)
            player?.isMuted = true
        }
        let playerGesture = UITapGestureRecognizer(target: self, action: #selector(playePause))
        player?.addGestureRecognizer(playerGesture)
        
        view.addSubview(activity)
        activity.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(playPauseButton)
        playPauseButton.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.center.equalTo(player?.snp.center ?? view.snp.center)
        }

    }
    
    @objc private func menu() {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        
        let download = UIAlertAction(title: "Download", style: .default) { [weak self] _ in
            self?.downloadVideo()
        }
        alert.addAction(download)
        
        let share = UIAlertAction(title: "Share video", style: .default) { [weak self] _ in
            self?.share()
        }
        alert.addAction(share)
        
        let del = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.delete()
        }
        alert.addAction(del)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
    
    private func delete() {
        if let index = model.generatedHistoryArr.firstIndex(where: {$0.generateID == item.generateID}) {
            model.generatedHistoryArr.remove(at: index)
            model.saveHistoryArr()
            backToRoot()
        }
    }
    
    private func share() {
        guard let urlString = item.videoUrl, let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }

    


    private func downloadVideo() {
        activity.startAnimating()
        // Убедимся, что URL корректный
        guard let videoUrlString = item.videoUrl, let videoUrl = URL(string: videoUrlString) else {
            print("Invalid video URL")
            return
        }
        
        // Скачиваем видео во временную директорию
        let tempFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedVideo.mp4")
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: videoUrl) { location, response, error in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                return
            }
            
            guard let location = location else {
                print("No file location")
                return
            }
            
            do {
                // Удаляем старый файл, если он существует
                if FileManager.default.fileExists(atPath: tempFilePath.path) {
                    try FileManager.default.removeItem(at: tempFilePath)
                }
                
                // Перемещаем загруженный файл во временную директорию с расширением .mp4
                try FileManager.default.moveItem(at: location, to: tempFilePath)
                
                // Сохраняем видео в галерею
                self.saveVideoToGallery(tempFilePath)
            } catch {
                print("Error handling file: \(error.localizedDescription)")
            }
        }
        
        downloadTask.resume()
    }

    private func saveVideoToGallery(_ fileUrl: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: fileUrl, options: nil)
        }) { [weak self] success, error in
            // Используем self, чтобы предотвратить утечку памяти
            DispatchQueue.main.async {
                if success {
                    self?.openAlert(isSucces: true)
                    print("Video saved to gallery successfully")
                } else if let error = error {
                    self?.openAlert(isSucces: false)
                    print("Error saving video: \(error.localizedDescription)")
                } else {
                    self?.openAlert(isSucces: false)
                    print("Unknown error occurred while saving video")
                }
            }
        }
    }


    private func openAlert(isSucces: Bool) {
        activity.stopAnimating()
        
        let alert = UIAlertController(title: isSucces ? "Success" : "Error", message: isSucces ? "Video uploaded to gallery" : "Video upload error", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: isSucces ? "Ok" : "Cancel", style: .cancel)
        alert.addAction(okAction)
        
        let retry = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
            self?.downloadVideo()
        }
        if !isSucces {
            alert.addAction(retry)
        }
        self.present(alert, animated: true)
    }
    
    @objc private func playePause() {
        if player?.state == .playing {
            playPauseButton.setImage(.pause, for: .normal)
            player?.pause(reason: .userInteraction)
        } else {
            playPauseButton.setImage(.play, for: .normal)
            player?.resume()
        }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.playPauseButton.alpha = 1
        } completion: { [weak self] finished in
            if finished {
                UIView.animate(withDuration: 0.5) { [weak self] in
                    self?.playPauseButton.alpha = 0
                }
            }
        }

    }

    
    deinit {
        print("deinittt")
        player?.pause(reason: .userInteraction)
        player = nil
    }

}
