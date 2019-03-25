//
//  AVUtility.swift
//  VideoCompress
//
//  Created by Dillon Hoa on 22/03/2019.
//  Copyright © 2019 Dillon Hoa. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

class AVUtility {
    
    static let fixedDimensions = 320
    static let fixedFramesPerSecond = 30
    /*
     * compressVideo static method
     * inputURL - URL of video
     * outputURL - export URL destination
     * handler - export session created
     * completion - upon completion of export with success (or not)
     */
    
    static func compressVideo(inputURL: URL,
                              outputURL: URL,
                              session:@escaping (_ exportSession: AVAssetExportSession?)-> Void,
                              completion:@escaping(_ exportSession: AVAssetExportSession?, _ success : Bool) -> Void) {
        
        let videoAsset: AVAsset = AVAsset( url: inputURL as URL )
        let videoTrack = videoAsset.tracks( withMediaType: .video ).first! as AVAssetTrack
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize( width: fixedDimensions, height: fixedDimensions )
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: Int32(fixedFramesPerSecond))
        
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: videoTrack.timeRange.duration)
        
        var scale : CGFloat = CGFloat(1.0)
        if videoTrack.naturalSize.height > videoTrack.naturalSize.width {
            scale = CGFloat(CGFloat(fixedDimensions)/videoTrack.naturalSize.width)
        } else {
            scale = CGFloat(CGFloat(fixedDimensions)/videoTrack.naturalSize.height)
        }
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        transformer.setTransform(CGAffineTransform(scaleX: scale, y: scale), at: .zero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        if let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetLowQuality) {
            session(exportSession);
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.m4v
            exportSession.videoComposition = videoComposition
            exportSession.exportAsynchronously {
                
                if exportSession.status == .completed {
                    print("Export complete")
                    DispatchQueue.main.async(execute: {
                        completion(exportSession,true)
                    })
                    return
                } else if exportSession.status == .failed {
                    print("Export error - \(String(describing: exportSession.error))")
                    completion(exportSession,false)
                }
            }
        } else {
            print("Session could not be created")
        }
    }
    
    /*
     * playVideo static method
     * videoURL URL of the video to be played
     * presentingVC is the presenting View Controller
     */
    
    static func playVideo(videoURL : URL, presentingVC: UIViewController) {
        let player = AVPlayer(url: videoURL)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        presentingVC.present(playerVC, animated: true) {
            playerVC.player!.play()
        }
    }
}
