//
//  ViewController.swift
//  VideoCompress
//
//  Created by Dillon Hoa on 22/03/2019.
//  Copyright © 2019 Dillon Hoa. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {

    @IBOutlet private weak var progressBar : UIProgressView?
    @IBOutlet private weak var pickVideoButton : UIButton?
    @IBOutlet private weak var watchVideoButton : UIButton?
    
    private let videoPicker = UIImagePickerController()
    private var progressTimer : Timer? = nil
    private var exportedVideoURL : URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoPicker.delegate = self
    }

    @IBAction private func pickVideo () {
        videoPicker.allowsEditing = false
        videoPicker.sourceType = .photoLibrary
        videoPicker.mediaTypes = [kUTTypeMovie as String]
        present(videoPicker, animated: true, completion: nil)
    }
    
    @IBAction private func watchVideo() {
        if let exportedURL = self.exportedVideoURL {
            AVUtility.playVideo(videoURL: exportedURL, presentingVC: self)
        }
    }
    
    private func updateProgresssBar(progress : Float) {
        if let progressBar = self.progressBar {
            progressBar.progress = progress
            progressBar.isHidden = progress == 0.0 || progress == 1.0
        }
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if videoURL.startAccessingSecurityScopedResource() {
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (videoURL.path)) {
                    let outputURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                    AVUtility.compressVideo(inputURL: videoURL, outputURL: outputURL, session: { (session) in
                        self.pickVideoButton?.setTitle("Exporting", for: .normal)
                        self.pickVideoButton?.isUserInteractionEnabled = false
                        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
                            if let validSession = session {
                                self.updateProgresssBar(progress: validSession.progress)
                            }
                        })
                        
                    }) { (session, success) in
                        self.pickVideoButton?.setTitle("Pick me!", for: .normal)
                        self.pickVideoButton?.isUserInteractionEnabled = true
                        self.progressTimer?.invalidate()
                        self.progressTimer = nil
                        if success {
                            self.exportedVideoURL = outputURL
                            if let button = self.watchVideoButton {
                                if (button.isHidden) {
                                    button.isHidden = false
                                    button.alpha = 0.0
                                    UIView.animate(withDuration: 0.3, animations: {
                                        button.alpha = 1.0;
                                    })
                                    
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

