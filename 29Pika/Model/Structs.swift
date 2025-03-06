//
//  Structs.swift
//  29Pika
//
//  Created by Владимир Кацап on 23.12.2024.
//

import Foundation

struct SortedEffects: Codable {
    let header: String
    var items: [Effect]
}

struct DataEffect: Codable {
    let error: Bool
    let messages: [String]
    let data: [Effect]
}

struct Effect: Codable {
    var id: Int
    var ai: String
    var effect: String
    var preview: String?
    var previewSmall: String?
    var localUrl: String?
}

// MARK: - UserInfo
struct UserInfo: Codable {
    let error: Bool
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let availableGenerations: Int
}

//MARK: -generate

struct Generate: Codable {
    let error: Bool
    let messages: [String]
    let data: DataGenerate
}

struct DataGenerate: Codable {
    let generationId: String
    let totalWeekGenerations: Int
    let maxGenerations: Int
}


//MARK: -get status
struct Status: Codable {
    let error: Bool?
    let messages: [String]?
    let data: StatusData?
}

struct StatusData: Codable {
    let status: String?
    let error: String?
    let resultUrl: String?
    let progress: Int?
    let totalWeekGenerations: Int?
    let maxGenerations: Int?
}

//MARK: User history effects

struct UserHistory: Codable, Identifiable {
    let id: UUID
    let nameEffect: String
    let idEffect: Int

    let imageOne: Data?

    var status: String?
    var generateID: String?
    var videoUrl: String?
    
    init(nameEffect: String, idEffect: Int,  imageOne: Data?, status: String?, generateID: String?, videoUrl: String?) {
        self.id = UUID()
        self.nameEffect = nameEffect
        self.idEffect = idEffect

        self.imageOne = imageOne

        self.status = status
        self.generateID = generateID
        self.videoUrl = videoUrl
    }
}
