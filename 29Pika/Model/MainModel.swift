//
//  MainModel.swift
//  29Pika
//
//  Created by Владимир Кацап on 12.12.2024.
//

import Foundation
import Combine
import GSPlayer

class MainModel {
    
    let purchaseManager = PurchaseManager()
    let purchasePublisher = PassthroughSubject<Any, Never>()
    let generatePublisher = PassthroughSubject<String, Never>()
    let netWorking = Networking()
    lazy var arr: [Effect] = []
    lazy var favoriteArrID: [Int] = DataFlow.loadFavoriteIdArrFromFile() ??  [10, 8, 55, 25]
    lazy var generatedHistoryArr: [UserHistory] = DataFlow.loadHistoryArrFromFile() ?? []
    
    var genIDArr: [String] = []
    var timers: [String: Timer] = [:]
    
    
    init() {
        netWorking.loadEffectsArr(escaping: { escaping in
            self.arr = escaping
            
            var arrURL: [URL] = []
            for i in self.arr {
                //print(i)
                if let url = URL(string: i.previewSmall ?? "") {
                    arrURL.append(url)
                }
            }
            
            VideoPreloadManager.shared.set(waiting: arrURL)
        })
        
        if let favorite = UserDefaults.standard.object(forKey: "favoriteID") as? [Int] {
            favoriteArrID = favorite
        }
        
        checkStatus()
    }
    
    
    func returnArr(type: typeArr) -> [Effect] {
        if type == .pika {
            return arr.filter({$0.ai == "pika"})
        } else {
            return arr.filter({$0.ai == "pv"})
        }
    }
    
    func saveFavoritesArr() {
        do {
            let data = try JSONEncoder().encode(favoriteArrID)
            try DataFlow.saveAthleteArrToFile(data: data)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    func createGenerate(image: Data, idEffect: Int, nameEffect: String, escaping: @escaping(String) -> Void) {
        
        netWorking.createVideo(data: image, idEffect: "\(idEffect)") { idGenerate in
            if idGenerate == "error" {
                escaping("error")
            } else {
                let item = UserHistory(nameEffect: nameEffect, idEffect: idEffect, imageOne: image, status: nil, generateID: idGenerate, videoUrl: nil)
                self.generatedHistoryArr.append(item)
                self.saveHistoryArr()
                escaping(idGenerate)
            }
        }
    }
    
    func saveHistoryArr() {
        do {
            let data = try JSONEncoder().encode(generatedHistoryArr)
            try DataFlow.saveHistoryToFile(data: data)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    func checkStatus() {
        genIDArr.removeAll()
        //timers.removeAll()
        print(generatedHistoryArr)
        for i in generatedHistoryArr {
            if i.status != "error" && (i.videoUrl == nil || i.videoUrl == "noVideo") {
                genIDArr.append(i.generateID ?? "")
            }
        }
        for id in genIDArr {
            startRetryTimer(for: id)
        }
    }
    
    private func startRetryTimer(for id: String) {
        if timers[id] == nil {
            let timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
                self?.retryCheckStatus(for: id)
            }
            timers[id] = timer
        }
    }
    
    private func retryCheckStatus(for id: String) {
        self.netWorking.getStatus(itemId: id) { status, urlVideo in
            DispatchQueue.main.async {
                if status != "error" {
                    if urlVideo == "noVideo" {
                        print("Видео всё ещё нет. Повторная проверка через 5 секунд для \(id)")
                    } else {
                        print("Видео найдено: \(status), \(urlVideo), \(id)")
                        self.removeTimer(for: id)
                        self.setStatusData(genID: id, status: status, videoURL: urlVideo)
                        self.generatePublisher.send((id))
                    }
                } else {
                    print("Ошибка при получении статуса: \(status), \(urlVideo), \(id)")
                    self.removeTimer(for: id)
                    self.setStatusData(genID: id, status: status, videoURL: urlVideo)
                    self.generatePublisher.send((id))
                }
            }
        }
    }
    
    private func removeTimer(for id: String) {
        if let timer = timers[id] {
            timer.invalidate()
            timers.removeValue(forKey: id)
        }
    }
    
    private func setStatusData(genID: String, status: String, videoURL: String?) {
        if let index = generatedHistoryArr.firstIndex(where: { $0.generateID == genID }) {
            generatedHistoryArr[index].status = status
            generatedHistoryArr[index].videoUrl = videoURL
            saveHistoryArr()
        }
    }
    
   
}

enum typeArr {
    case pika
    case px
}
