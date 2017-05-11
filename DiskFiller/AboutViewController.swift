import UIKit

class AboutViewController: UIViewController {

    @IBOutlet var backgroundView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = #imageLiteral(resourceName: "winking_kitten.jpg").blurred()
        backgroundView.image = image
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }

    @IBAction func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func githubTapped() {
        openLink(withURLString: "https://github.com/adriaan/DiskFiller")
    }

    @IBAction func kinomaticTapped() {
        openLink(withURLString: "https://itunes.apple.com/us/app/kinomatic-video-camera-editing/id785103743?mt=8&at=11l5JX")
    }

    @IBAction func videoSlamTapped() {
        openLink(withURLString: "https://itunes.apple.com/us/app/videoslam-instant-video-compilations-from-your-videos/id1069545900?mt=8&at=11l5JX")
    }

    @IBAction func tinyPlanetsTapped() {
        openLink(withURLString: "https://itunes.apple.com/us/app/tiny-planet-photos/id425996445?mt=8&at=11l5JX")
    }

    @IBAction func backgroundImageCreditTapped() {
        openLink(withURLString: "https://www.flickr.com/photos/tambako/6147416186/")
    }

    private func openLink(withURLString urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.openURL(url)
    }
}

