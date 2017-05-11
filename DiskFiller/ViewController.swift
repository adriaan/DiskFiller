import UIKit

class ViewController: UIViewController, FileHandlerDelegate {

    @IBOutlet var fillButton: UIButton!
    @IBOutlet var removeSomeButton: UIButton!
    @IBOutlet var clearAllButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var diskSpaceLabel: UILabel!
    @IBOutlet var diskSpaceProgess: UIProgressView!
    @IBOutlet var numFilesLabel: UILabel!
    @IBOutlet var backgroundView: UIImageView!

    let fileHandler = FileHandler()
    let diskSpaceHelper = DiskSpaceHelper()
    private var shouldRemoveSome = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = #imageLiteral(resourceName: "winking_kitten.jpg").blurred()
        backgroundView.image = image
        fileHandler.delegate = self
        configureButtons()
        enableButtons()
        updateDiskSpaceDisplay()
    }

    @objc func userDidTap(fillButton: UIButton) {
        disableButtons()
        fileHandler.fillDisk()
    }

    @objc func userDidTap(removeSomeButton: UIButton) {
        disableButtons()
        fileHandler.removeSomeFiles(numberOfFiles: 1)
    }

    @objc func userDidTouchDown(removeSomButton: UIButton) {
        shouldRemoveSome = true
        disableButtons()
        removeSomeFiles()
    }

    @objc func userDidCancel(removeSomeButton: UIButton) {
        shouldRemoveSome = false
    }

    @objc func userDidTap(clearAllButton: UIButton) {
        disableButtons()
        fileHandler.removeAllFiles()
    }

    @objc func userDidTap(stopButton: UIButton) {
        fileHandler.shouldStop = true
    }

    private func updateDiskSpaceDisplay() {
        if let availableSpace = diskSpaceHelper.availableDiskSpace {
            updateDiskSpaceLabel(withDiskSpace: "\(availableSpace / (1024*1024)) Mb")
        } else {
            updateDiskSpaceLabel(withDiskSpace: "unknown")
        }
        if let fractionUsed = diskSpaceHelper.fractionDiskSpaceUsed {
            diskSpaceProgess.progress = fractionUsed
        }
        if let numberOfFiles = fileHandler.numberOfFilesStored {
            updateNumFilesLabel(withNumberOfFiles: "\(numberOfFiles)")
        } else {
            updateNumFilesLabel(withNumberOfFiles: "unknown")
        }
    }

    private func updateDiskSpaceLabel(withDiskSpace diskSpace: String) {
        diskSpaceLabel.text = "Available disk space: " + diskSpace
    }

    private func updateNumFilesLabel(withNumberOfFiles numberOfFiles: String) {
        numFilesLabel.text = "Number of kittens stored: " + numberOfFiles
    }

    private func configureButtons() {
        fillButton.addTarget(self, action: #selector(userDidTap(fillButton:)), for: .touchUpInside)
        removeSomeButton.addTarget(self, action: #selector(userDidTouchDown(removeSomButton:)), for: .touchDown)
        removeSomeButton.addTarget(self, action: #selector(userDidCancel(removeSomeButton:)), for: [.touchCancel, .touchUpInside, .touchUpOutside])
        clearAllButton.addTarget(self, action: #selector(userDidTap(clearAllButton:)), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(userDidTap(stopButton:)), for: .touchUpInside)
    }

    private func enableButtons() {
        fillButton.isEnabled = true
        removeSomeButton.isEnabled = true
        clearAllButton.isEnabled = true
        stopButton.isEnabled = false
        stopButton.alpha = 0
    }

    private func disableButtons() {
        fillButton.isEnabled = false
        removeSomeButton.isEnabled = false
        clearAllButton.isEnabled = false
        if shouldRemoveSome == false {
            stopButton.isEnabled = true
            stopButton.alpha = 1
        }
    }

    @objc private func removeSomeFiles() {
        if shouldRemoveSome {
            fileHandler.removeSomeFiles(numberOfFiles: 1)
        } else {
            enableButtons()
        }
    }

    private func handleError(error: FileHandlingError) {
        let controller = UIAlertController(title: error.shortDescription, message: error.description, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { _ in
            controller.dismiss(animated: true, completion: nil)
        }
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }

    //MARK: FileHandlerDelegate methods

    func fileHandlerDidAddFile(fileHander: FileHandler) {
        DispatchQueue.main.async {
            self.updateDiskSpaceDisplay()
        }
    }

    func fileHandlerDidFinishAddingFiles(fileHander: FileHandler) {
        DispatchQueue.main.async {
            self.enableButtons()
        }
    }

    func fileHandlerDidRemoveFile(fileHander: FileHandler) {
        DispatchQueue.main.async {
            self.updateDiskSpaceDisplay()
        }
    }

    func fileHandlerDidFinishRemovingFiles(fileHander: FileHandler) {
        DispatchQueue.main.async {
            if self.shouldRemoveSome == false {
                self.enableButtons()
            } else {
                self.perform(#selector(self.removeSomeFiles), with: nil, afterDelay: 0.1)
            }
        }
    }
    
    func fileHandler(fileHander: FileHandler, didFailWithError error: FileHandlingError) {
        DispatchQueue.main.async {
            self.enableButtons()
            self.shouldRemoveSome = false
            self.handleError(error: error)
        }
    }

    func fileHandlerDidCancel(fileHander: FileHandler) {
        DispatchQueue.main.async {
            self.enableButtons()
        }
    }
}
