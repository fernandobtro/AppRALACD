//
//  ViewController.swift
//  AppRA
//
//  Created by Fernando Buenrostro on 14/04/23.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
        
        @IBOutlet var sceneView: ARSCNView!
        var videoNodes: [String: SKVideoNode] = [:]
        var lastDetectedImageName: String?

        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Set the view's delegate
            sceneView.delegate = self
            
            // Show statistics such as fps and timing information
            sceneView.showsStatistics = false
            
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Create a session configuration
            let configuration = ARImageTrackingConfiguration()
            
            if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "NewsPaperImages", bundle: Bundle.main) {
                configuration.trackingImages = trackedImages
                configuration.maximumNumberOfTrackedImages = trackedImages.count
                print("Images found")
            }
            
            // Run the view's session
            sceneView.session.run(configuration)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // Pause the view's session
            sceneView.session.pause()
        }
        
        // MARK: - ARSCNViewDelegate
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            let node = SCNNode()
            
            if let imageAnchor = anchor as? ARImageAnchor {
                let imageName = imageAnchor.referenceImage.name ?? ""
                lastDetectedImageName = imageName

                
                if let videoNode = videoNodes[imageName] ?? createVideoNode(filename: imageName) {
                    videoNodes[imageName] = videoNode
                    
                    videoNode.play()
                    print("\(imageName) tracked")
                    
                    let videoScene = SKScene(size: CGSize(width: 1280, height: 720))
                    
                    videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
                    
                    videoNode.yScale = -1.0
                    
                    videoScene.addChild(videoNode)
                    
                    
                    let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
                    
                    plane.firstMaterial?.diffuse.contents = videoScene
                    
                    let planeNode = SCNNode(geometry: plane)
                    
                    planeNode.eulerAngles.x = -.pi / 2
                    
                    node.addChildNode(planeNode)
                }
            }
            
            return node
        }
    
        
        func createVideoNode(filename: String) -> SKVideoNode? {
            guard let path = Bundle.main.path(forResource: filename, ofType: "mp4") else { return nil }
            let url = URL(fileURLWithPath: path)
            let videoPlayer = AVPlayer(url: url)
            let videoNode = SKVideoNode(avPlayer: videoPlayer)
            videoNode.size = CGSize(width: 1280, height: 720)
            videoPlayer.volume = 1.0
            videoPlayer.actionAtItemEnd = .pause
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: nil) { (_) in
                videoPlayer.seek(to: .zero)
                videoPlayer.volume = 0.0
                videoNode.pause()
            }
            return videoNode
        }
    
    
}
