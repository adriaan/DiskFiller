import Foundation

final class FileHandler {

    weak var delegate: FileHandlerDelegate?
    let fileManager = FileManager.default
    let fileHandlingQueue = DispatchQueue.global(qos: .userInitiated)
    var shouldStop = false

    let documentsPath: String?
    let sourcePath: String? = Bundle.main.path(forResource: "winking_kitten", ofType: "jpg")

    var numberOfFilesStored: Int?

    init() {
        let searchPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        documentsPath = searchPaths.first
        initialiseNumFiles()
    }

    func fillDisk() {
        shouldStop = false
        guard let documentsPath = documentsPath, let sourcePath = sourcePath else {
            delegate?.fileHandler(fileHander: self, didFailWithError: FileHandlingError.documentsPathNotFound)
            return
        }
        fileHandlingQueue.async {
            do {
                let imageData = try Data(contentsOf: URL(fileURLWithPath: sourcePath))
                let filePaths = try self.fileManager.contentsOfDirectory(atPath: documentsPath)
                var i = filePaths.count
                self.numberOfFilesStored = i
                var proceed = true
                while proceed {
                    let fileName = "/file\(i).jpg"
                    let filePath = documentsPath.appending(fileName)
                    if !self.fileManager.fileExists(atPath: filePath) {
                        do {
                            try imageData.write(to: URL(fileURLWithPath: filePath))
                            self.delegate?.fileHandlerDidAddFile(fileHander: self)
                            self.incrementFilesStored()
                        } catch {
                            proceed = false
                            self.delegate?.fileHandlerDidFinishAddingFiles(fileHander: self)
                        }
                    }
                    if self.shouldStop {
                        self.delegate?.fileHandlerDidCancel(fileHander: self)
                        return
                    }
                    i += 1
                }
            } catch {
                self.delegate?.fileHandler(fileHander: self, didFailWithError: FileHandlingError.documentsPathNotFound)
            }
        }
    }

    func removeSomeFiles(numberOfFiles: Int) {
        shouldStop = false
        guard let documentsPath = documentsPath else {
            delegate?.fileHandler(fileHander: self, didFailWithError: FileHandlingError.documentsPathNotFound)
            return
        }
        fileHandlingQueue.async {
            do {
                let filePaths = try self.fileManager.contentsOfDirectory(atPath: documentsPath)
                let numToDelete = min(numberOfFiles, filePaths.count)
                guard numToDelete > 0 else {
                    self.delegate?.fileHandlerDidFinishRemovingFiles(fileHander: self)
                    return
                }
                for i in 0..<numToDelete {
                    let path = "\(documentsPath)/\(filePaths[i])"
                    self.removeFile(atPath: path)
                }
                self.delegate?.fileHandlerDidFinishRemovingFiles(fileHander: self)
            } catch {
                self.delegate?.fileHandler(fileHander: self, didFailWithError: FileHandlingError.documentsPathNotFound)
            }
        }
    }

    func removeAllFiles() {
        shouldStop = false
        guard let documentsPath = documentsPath else {
            delegate?.fileHandler(fileHander: self, didFailWithError: FileHandlingError.documentsPathNotFound)
            return
        }
        fileHandlingQueue.async {
            do {
                let filePaths = try self.fileManager.contentsOfDirectory(atPath: documentsPath)
                for filePath in filePaths {
                    let path = "\(documentsPath)/\(filePath)"
                    self.removeFile(atPath: path)
                    if self.shouldStop {
                        self.delegate?.fileHandlerDidCancel(fileHander: self)
                        return
                    }
                }
                self.delegate?.fileHandlerDidFinishRemovingFiles(fileHander: self)
            } catch {
                self.delegate?.fileHandler(fileHander: self, didFailWithError: FileHandlingError.documentsPathNotFound)
            }
        }
    }

    private func incrementFilesStored() {
        guard let numFiles = numberOfFilesStored else {
            initialiseNumFiles()
            return
        }
        numberOfFilesStored = numFiles + 1
    }

    private func decrementFilesStored() {
        guard let numFiles = numberOfFilesStored else {
            initialiseNumFiles()
            return
        }
        numberOfFilesStored = max(numFiles - 1, 0)
    }

    private func initialiseNumFiles() {
        guard let documentsPath = documentsPath, let filePaths = try? self.fileManager.contentsOfDirectory(atPath: documentsPath) else { return }
        numberOfFilesStored = filePaths.count
    }

    private func removeFile(atPath path: String) {
        guard fileManager.fileExists(atPath: path) else { return }
        do {
            try fileManager.removeItem(atPath: path)
            decrementFilesStored()
            delegate?.fileHandlerDidRemoveFile(fileHander: self)
        } catch {
            delegate?.fileHandler(fileHander: self, didFailWithError: FileHandlingError.failedToDelete)
        }
    }
}

protocol FileHandlerDelegate: class {
    func fileHandlerDidAddFile(fileHander: FileHandler)
    func fileHandlerDidRemoveFile(fileHander: FileHandler)
    func fileHandlerDidFinishAddingFiles(fileHander: FileHandler)
    func fileHandlerDidFinishRemovingFiles(fileHander: FileHandler)
    func fileHandler(fileHander: FileHandler, didFailWithError error: FileHandlingError)
    func fileHandlerDidCancel(fileHander: FileHandler)
}

enum FileHandlingError: Error {
    case failedToDelete
    case failedToCopy
    case documentsPathNotFound

    var shortDescription: String {
        switch self {
        case .failedToCopy:
            return "Failed to save file"
        case .failedToDelete:
            return "Failed to delete file"
        case .documentsPathNotFound:
            return "Documents folder not found"
        }
    }
    
    var description: String {
        switch self {
        case .failedToCopy:
            return "Copying and saving a kitten failed. Please try again..."
        case .failedToDelete:
            return "Our attemts to delete a kitten from your hard drive failed. Please try again..."
        case .documentsPathNotFound:
            return "We couldn't find the folder we use for storing kittens."
        }
    }
}
