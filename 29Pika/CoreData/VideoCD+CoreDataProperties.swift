

import Foundation
import CoreData


extension VideoCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoCD> {
        return NSFetchRequest<VideoCD>(entityName: "VideoCD")
    }

    @NSManaged public var id: Int32
    @NSManaged public var previewUrl: String
    @NSManaged public var effect: String
    @NSManaged public var smallPreviewUrl: String
    @NSManaged public var ai: String
    @NSManaged public var category: String
}

extension VideoCD : Identifiable {

}
