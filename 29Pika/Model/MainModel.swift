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
    
    var tokens: Int = 0
    var connectionAvailable = false
    
    let coredataManager = CoreDataManager()
    let documentManager = DocumentManager()
    
    let purchaseManager = PurchaseManager()
    let purchasePublisher = PassthroughSubject<Any, Never>()
    let generatePublisher = PassthroughSubject<String, Never>()
    let arrChangedPublisher = PassthroughSubject<Bool, Never>()
    let netWorking = Networking()
    lazy var arr1: [Effect] = []
    lazy var arr: [SortedEffects] = [] {
        didSet {
            //print("Changed")
            arrChangedPublisher.send(true)
        }
    }
    lazy var favoriteArrID: [Int] = DataFlow.loadFavoriteIdArrFromFile() ??  [10, 8, 55, 25]
    lazy var generatedHistoryArr: [UserHistory] = DataFlow.loadHistoryArrFromFile() ?? []
    
    var genIDArr: [String] = []
    var timers: [String: Timer] = [:]
    
    var isSecondType = true
    
    init() {
        localLoad()
        netWorking.buyTokens(apphudId: userID, tokens: 10) { tokens in
            print("Tokens buyed")
            print(tokens)
        } errorHandler: {
            
        }

        netWorking.fetchCurrentTokens(apphudId: userID) { availableTokens in
            self.tokens = availableTokens
        } errorHandler: {
            
        }

        if UserDefaults.standard.object(forKey: "onb") == nil {
            DispatchQueue.global(qos: .userInteractive).async {
                self.firstLaunchLoad()
            }
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                self.load()
            }
        }
        if let isSecond = try? coredataManager.fetchIsSecond() {
            isSecondType = isSecond
        }
        netWorking.experiment(apphudId: userID) { bool in
            self.isSecondType = bool
            self.coredataManager.saveOrEdit(isSecond: bool)
        } errorHandler: {
            
        }
        
        checkStatus()
    }
    
    func firstLaunchLoad() {
        try? coredataManager.clearCache()
        netWorking.fetchTemplatesByCategory { templates in
            templates.data.forEach { data in
                if !self.arr.contains(where: {$0.header == data.categoryTitleEn}) {
                    self.arr.append(SortedEffects(header: data.categoryTitleEn, items: []))
                }
                data.templates.forEach { template in
                    print(template.effect)
                    guard let categoryIndex = self.arr.firstIndex(where: {data.categoryTitleEn == $0.header}) else { return }
                    var effect = Effect(id: template.id, ai: template.ai.rawValue, effect: template.effect, preview: template.preview, previewSmall: template.previewSmall)
                    self.documentManager.removeVideoBy(filename: "\(effect.id).mp4")
                    if let urlStr = effect.previewSmall {
                        self.coredataManager.save(effect: effect, category: data.categoryTitleEn)
                        self.documentManager.downloadVideo(urlStr: urlStr, id: effect.id) { str in
                            //self.coredataManager.edit(effect: effect, category: data.categoryTitleEn)
                            print("SAVED TO LOCAL URL: " + str)
                            if let index = self.arr[categoryIndex].items.firstIndex(where: {$0.id == effect.id}) {
                                self.arr[categoryIndex].items[index].localUrl = str
                            } else { effect.localUrl = str }
                        }
                        self.arr[categoryIndex].items.append(effect)
                    }
                }
            }
        } errorHandler: {
            
        }
    }
    
    func localLoad() {
        print("Local init load")
        guard let effectsCD = try? coredataManager.fetchEffects() else { return }
        print("Effects fetched")
        guard !effectsCD.isEmpty else { return }
        effectsCD.forEach { effectCD in
            
            if !self.arr.contains(where: {$0.header == effectCD.0}) {
                arr.append(SortedEffects(header: effectCD.0, items: []))
            }
            
            guard let categoryIndex = arr.firstIndex(where: {$0.header == effectCD.0}) else { return } //Категория 100% есть
            var effect = effectCD.1
            print("Local url Test: \(effect.id) " + effect.effect + " " + (effect.localUrl ?? "Error: cannot get local url"))
            if let localVideoUrl = documentManager.fetchVideoFromDocuments(filename: "\(effect.id).mp4") {
                effect.localUrl = localVideoUrl
            } else if let smallPreview = effect.previewSmall { //Если в прошлый раз при использовании прилы загрузиться не успело
                documentManager.downloadVideo(urlStr: smallPreview, id: effect.id) { urlStr in
                    if let index = self.arr[categoryIndex].items.firstIndex(where: {$0.id == effect.id}) {
                        self.arr[categoryIndex].items[index].localUrl = urlStr
                    } else { effect.localUrl = urlStr }
                }
            }
            arr[categoryIndex].items.append(effect)
        }
        let index = self.arr.firstIndex(where: {$0.header == "Popular"})
        if let index = index {
            let val = self.arr[index]
            self.arr.remove(at: index)
            self.arr.insert(val, at: 0)
        }
    }
    
    func load() {
        netWorking.fetchTemplatesByCategory { templates in
            self.removeUnnecessaryElements(templates: templates)
            
            //добавляем категории если их нет
            templates.data.forEach { data in
                if !self.arr.contains(where: {$0.header == data.categoryTitleEn}) { //добавляем категорию если есть новая
                    self.arr.append(SortedEffects(header: data.categoryTitleEn, items: []))
                }
                guard let categoryIndex = self.arr.firstIndex(where: {$0.header == data.categoryTitleEn}) else { return } //на этом этапе у нас 100% есть нужная категория
                data.templates.forEach { effectServer in
                    if let effectIndex = self.arr[categoryIndex].items.firstIndex(where: {$0.id == effectServer.id}) { //Если эффект у нас уже существует
                        //меняем эффект если нужно и сохраняем
                        if !self.isEqualEffectAndTemplate(effect: self.arr[categoryIndex].items[effectIndex], template: effectServer) { //Если локальный эффект не совпадает с сервером
                            var effect = Effect(id: effectServer.id, ai: effectServer.ai.rawValue, effect: effectServer.effect, preview: effectServer.preview, previewSmall: effectServer.previewSmall) //обновили эффект
                            self.coredataManager.saveOrEdit(effect: effect, category: data.categoryTitleEn) //обновили или добавили эффект в память
                            if !(effectServer.previewSmall == self.arr[categoryIndex].items[effectIndex].previewSmall) { //Если превью не совпадает в документы на то же имя качаем новое
                                self.documentManager.removeVideoBy(filename: "\(effect.id).mp4")
                                self.documentManager.downloadVideo(urlStr: effectServer.previewSmall, id: effectServer.id) { str in //Загружаем превью в память
                                    print("SAVED TO LOCAL URL: " + str)
                                    if let index = self.arr[categoryIndex].items.firstIndex(where: {$0.id == effect.id}) {
                                        self.arr[categoryIndex].items[index].localUrl = str
                                    } else { effect.localUrl = str }
                                }
                            }
                            self.arr[categoryIndex].items[effectIndex] = effect
                        } else { //Если локальный эффект совпадает с сервером
                            //ничего не делаем, у нас нормас он подгружен
                        }
                        
                        //var effect = Effect(id: effectServer.id, ai: effectServer.ai.rawValue, effect: effectServer.)
                    } else { //Если эффект не существует создаем
                        var effect = Effect(id: effectServer.id, ai: effectServer.ai.rawValue, effect: effectServer.effect, preview: effectServer.preview, previewSmall: effectServer.previewSmall) //создали эффект
                        self.coredataManager.saveOrEdit(effect: effect, category: data.categoryTitleEn) //обновили или добавили эффект в память
                        self.documentManager.removeVideoBy(filename: "\(effect.id).mp4")
                        self.documentManager.downloadVideo(urlStr: effectServer.previewSmall, id: effectServer.id) { str in //Загружаем превью в память
                            print("SAVED TO LOCAL URL: " + str)
                            if let index = self.arr[categoryIndex].items.firstIndex(where: {$0.id == effect.id}) {
                                self.arr[categoryIndex].items[index].localUrl = str
                            } else { effect.localUrl = str }
                        }
                        self.arr[categoryIndex].items.append(effect)
                    }
                }
                
            }
            
        } errorHandler: {
            
        }
    }
    
    func isEqualEffectAndTemplate(effect: Effect, template: Template) -> Bool {
        if effect.effect != template.effect ||
            effect.previewSmall != template.previewSmall ||
            effect.ai != template.ai.rawValue ||
            effect.preview != template.preview {
            return false
        } else {
            return true
        }
    }
    
    func removeUnnecessaryElements(templates: TemplatesByCategory) {
        //удаляем лишнее из coreData
        self.arr.forEach { sortedEffect in
            if let index = templates.data.firstIndex(where: {$0.categoryTitleEn == sortedEffect.header}) {
                //проверяем и если надо удаляем лишние эффекты из coreData
                sortedEffect.items.forEach { effect in
                    if !templates.data[index].templates.contains(where: {$0.id == effect.id}) {
                        try? self.coredataManager.remove(id: effect.id)
                        print("effect removed \(effect.id)")
                    }
                }
            } else {
                //проверяем и если надо удаляем лишние категории вместе с эффектами из coreData
                sortedEffect.items.forEach { effect in
                    try? self.coredataManager.remove(id: effect.id)
                    print("effect removed \(effect.id)")
                }
            }
        }
    }
    
    func load1() {
        netWorking.fetchTemplatesByCategory { templates in
            //удаляем лишнее из coreData
            self.arr.forEach { sortedEffect in
                if let index = templates.data.firstIndex(where: {$0.categoryTitleEn == sortedEffect.header}) {
                    //проверяем и если надо удаляем лишние эффекты из coreData
                    sortedEffect.items.forEach { effect in
                        if !templates.data[index].templates.contains(where: {$0.id == effect.id}) {
                            try? self.coredataManager.remove(id: effect.id)
                            print("effect removed \(effect.id)")
                        }
                    }
                } else {
                    //проверяем и если надо удаляем лишние категории вместе с эффектами из coreData
                    sortedEffect.items.forEach { effect in
                        try? self.coredataManager.remove(id: effect.id)
                        print("effect removed \(effect.id)")
                    }
                }
            }
            
            //добавляем если надо что-то в coreData и массив эффектов
            templates.data.forEach { data in
                if !data.templates.isEmpty {
                    if let categoryIndex = self.arr.firstIndex(where: {$0.header == data.categoryTitleEn}) { //Если категория уже существует
                        
                        data.templates.forEach { template in
                            var effect = Effect(id: template.id, ai: template.ai.rawValue, effect: template.effect, preview: template.preview, previewSmall: template.previewSmall)
                            if let effectIndex = self.arr[categoryIndex].items.firstIndex(where: {$0.id == effect.id}) { //Если эффект есть в массиве, то изменяем
                                if let localUrl = self.arr[categoryIndex].items[effectIndex].localUrl { //если local url уже есть
                                    if self.arr[categoryIndex].items[effectIndex].previewSmall != effect.previewSmall { //обновить видео в documents directory
                                        self.documentManager.removeVideoBy(filename: "\(effect.id).mp4")
                                        if let urlStr = effect.previewSmall {
                                            self.documentManager.downloadVideo(urlStr: urlStr, id: effect.id) { str in
                                                //self.coredataManager.edit(effect: effect, category: data.categoryTitleEn)
                                                print("SAVED TO LOCAL URL: " + str)
                                                self.arr[categoryIndex].items[effectIndex].localUrl = str
                                            }
                                        }
                                    } else { //обновлять не надо
                                        effect.localUrl = localUrl
                                    }
                                }
                                effect.localUrl = self.arr[categoryIndex].items[effectIndex].localUrl
                                self.arr[categoryIndex].items[effectIndex] = effect
                            } else { //если нет, то добавляем эффект в массив
                                self.documentManager.removeVideoBy(filename: "\(effect.id).mp4")
                                self.arr[categoryIndex].items.append(effect)
                                if let urlStr = effect.previewSmall {
                                    self.documentManager.downloadVideo(urlStr: urlStr, id: effect.id) { str in
                                        effect.localUrl = str
                                        if let index = self.arr[categoryIndex].items.firstIndex(where: {$0.id == effect.id}) {
                                            self.arr[categoryIndex].items[index].localUrl = str
                                        }
                                    }
                                }
                            }
                            
                            self.coredataManager.saveOrEdit(effect: effect, category: data.categoryTitleEn)
                        }
                    } else {//если категория не существует
                        var effects: Array<Effect> = []
                        data.templates.forEach { template in
                            var effect = Effect(id: template.id, ai: template.ai.rawValue, effect: template.effect, preview: template.preview, previewSmall: template.previewSmall)
                            self.documentManager.removeVideoBy(filename: "\(effect.id).mp4")
                            if let urlStr = effect.previewSmall {
                                self.documentManager.downloadVideo(urlStr: urlStr, id: effect.id) { str in
                                    //self.coredataManager.edit(effect: effect, category: data.categoryTitleEn)
                                    print("SAVED TO LOCAL URL: " + str)
                                    if let index = self.arr.firstIndex(where: {$0.header == data.categoryTitleEn}) {
                                        if let effectIndex = self.arr[index].items.firstIndex(where: {$0.id == effect.id}) {
                                            self.arr[index].items[effectIndex].localUrl = str
                                        }
                                    } else {
                                        effect.localUrl = str
                                    }
                                }
                            }
                            effects.append(effect)
                            self.coredataManager.saveOrEdit(effect: effect, category:  data.categoryTitleEn)
                        }
                        self.arr.append(SortedEffects(header: data.categoryTitleEn, items: effects))
                        
                    }
                    //self.arr.append(SortedEffects(header: data.categoryTitleEn, items: effects))
                }
            }
            let index = self.arr.firstIndex(where: {$0.header == "Popular"})
            if let index = index {
                let val = self.arr[index]
                self.arr.remove(at: index)
                self.arr.insert(val, at: 0)
            }
        } errorHandler: {
            
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
