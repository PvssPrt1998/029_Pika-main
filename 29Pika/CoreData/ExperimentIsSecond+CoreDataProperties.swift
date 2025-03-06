//
//  ExperimentIsSecond+CoreDataProperties.swift
//  29Pika
//
//  Created by Николай Щербаков on 05.03.2025.
//
//

import Foundation
import CoreData


extension ExperimentIsSecond {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExperimentIsSecond> {
        return NSFetchRequest<ExperimentIsSecond>(entityName: "ExperimentIsSecond")
    }

    @NSManaged public var isSecond: Bool

}

extension ExperimentIsSecond : Identifiable {

}
