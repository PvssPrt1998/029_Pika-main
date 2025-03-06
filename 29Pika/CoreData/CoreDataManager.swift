import Foundation
import CoreData

class CoreDataManager {
    
    private let modelName = "VideoCD"
    
    lazy var coreDataStack = CoreDataStack(modelName: modelName)
    
    func saveOrEdit(isSecond: Bool) {
        do {
            let isSecondCD = try coreDataStack.managedContext.fetch(ExperimentIsSecond.fetchRequest())
            if isSecondCD.isEmpty {
                let isSecondCD = ExperimentIsSecond(context: coreDataStack.managedContext)
                isSecondCD.isSecond = isSecond
            } else {
                isSecondCD[0].isSecond = isSecond
            }
            coreDataStack.saveContext()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func clearCache() throws {
        let videosCD = try coreDataStack.managedContext.fetch(VideoCD.fetchRequest())
        videosCD.forEach { videoCD in
            coreDataStack.managedContext.delete(videoCD)
        }
        coreDataStack.saveContext()
    }
    
    func fetchIsSecond() throws -> Bool  {
        return try coreDataStack.managedContext.fetch(ExperimentIsSecond.fetchRequest()).first?.isSecond ?? true
    }
    
    func save(effect: Effect, category: String) {
        let videoCD = VideoCD(context: coreDataStack.managedContext)
        videoCD.id = Int32(effect.id)
        videoCD.previewUrl = effect.preview ?? ""
        videoCD.smallPreviewUrl = effect.previewSmall ?? ""
        videoCD.ai = effect.ai
        videoCD.effect = effect.effect
        videoCD.category = category
        coreDataStack.saveContext()
    }
    
    func saveOrEdit(effect: Effect, category: String) {
        do {
            let videosCD = try coreDataStack.managedContext.fetch(VideoCD.fetchRequest())
            var founded = false
            videosCD.forEach { videoCD in
                if videoCD.id == effect.id {
                    founded = true
                    videoCD.previewUrl = effect.preview ?? ""
                    videoCD.smallPreviewUrl = effect.previewSmall ?? ""
                    videoCD.ai = effect.ai
                    videoCD.effect = effect.effect
                    videoCD.category = category
                    coreDataStack.saveContext()
                    return
                }
            }
            
            if !founded {
                save(effect: effect, category: category)
            }
            
            coreDataStack.saveContext()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func edit(effect: Effect, category: String) {
        do {
            let videosCD = try coreDataStack.managedContext.fetch(VideoCD.fetchRequest())
            videosCD.forEach { videoCD in
                if videoCD.id == effect.id {
                    videoCD.previewUrl = effect.preview ?? ""
                    videoCD.smallPreviewUrl = effect.previewSmall ?? ""
                    videoCD.ai = effect.ai
                    videoCD.effect = effect.effect
                    videoCD.category = category
                }
            }
            coreDataStack.saveContext()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func remove(id: Int) throws {
        let videosCD = try coreDataStack.managedContext.fetch(VideoCD.fetchRequest())
        guard let videoCD = videosCD.first(where: {$0.id == id}) else { return }
        coreDataStack.managedContext.delete(videoCD)
        coreDataStack.saveContext()
    }

    func fetchEffects() throws -> Array<(String, Effect)> {
        var array: Array<(String, Effect)> = []
        let effects = try coreDataStack.managedContext.fetch(VideoCD.fetchRequest())
        effects.forEach { videoCD in
            array.append((videoCD.category, Effect(id: Int(videoCD.id), ai: videoCD.ai, effect: videoCD.effect, preview: videoCD.previewUrl, previewSmall: videoCD.smallPreviewUrl)))
        }
        return array
    }
}

