import Foundation

final class DiskSpaceHelper {

    private let documentPath: String?

    var availableDiskSpace: Int? {
        guard let attributes = fileSystemAttributes, let freeSpaceInBytes = attributes[FileAttributeKey.systemFreeSize] as? NSNumber else { return nil }
        return freeSpaceInBytes.intValue
    }

    var fractionDiskSpaceUsed: Float? {
        guard let attributes = fileSystemAttributes,
            let freeSpaceInBytes = attributes[FileAttributeKey.systemFreeSize] as? NSNumber,
            let totalSpaceInBytes = attributes[FileAttributeKey.systemSize] as? NSNumber else { return nil }
        return (totalSpaceInBytes.floatValue - freeSpaceInBytes.floatValue)/totalSpaceInBytes.floatValue
    }

    private var fileSystemAttributes: [FileAttributeKey: Any]? {
        guard let path = documentPath else { return nil }
        do {
            let dictionary = try FileManager.default.attributesOfFileSystem(forPath: path)
            return dictionary
        } catch {
            return nil
        }
    }

    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        documentPath = paths.last
    }

}
