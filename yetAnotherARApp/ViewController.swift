import UIKit
import SceneKit
import ARKit

struct SmileFrame: Codable {
    var leftSide: Double
    var rightSide: Double
    var time: Double
}

struct MemeData: Codable {
    var isFunny: Bool
    var dataSet: [SmileFrame]
}

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var TraininSessionView: UIView!
    
    let coachingOverlay = ARCoachingOverlayView()
    
    let configuration = ARFaceTrackingConfiguration()
    
    var counterImageSet = ["3", "2", "1"]
    
    var counterImageSetCopy = ["3", "2", "1"]
    
    var memeCollection = [""]
    
    var counterTimer: Timer?
    
    var counter = 0
    
    var memeDataSet = [SmileFrame]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memeCollection.removeAll()
        
        for i in 0...3 {
            
            var memeName = "meme" + String(i)
            
            memeCollection.append(memeName)
            
        }
        
        TraininSessionView.isHidden = true
        
//        configureGesturesForScene()
//
//        // Set the view's delegate
//        sceneView.delegate = self

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureARsession()

        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("SESSION IS PAUSED")
        
        sceneView.session.pause()
    
        
    }
    
    //setups the initial ARSession
    func configureARsession(){
        
      //        guard let referenceImage = ARReferenceImage.referenceImages(inGroupNamed: "photo", bundle: nil) else {
      //            print("cant find IMAGES")
      //            return}
      //
      //        let configurationTwo = ARImageTrackingConfiguration()
      //        configurationTwo.trackingImages = referenceImage
      //        configurationTwo.maximumNumberOfTrackedImages = 1
      //        sceneView.session.run(configurationTwo)
      //
//              configuration.planeDetection = [.horizontal, .vertical]\
      //        configuration.userFaceTrackingEnabled = true
              
      //        configuration.detectionImages = referenceImage
      //        configuration.maximumNumberOfTrackedImages = 1
//              sceneView.session.run(configuration)

              sceneView.session.delegate = self
              sceneView.delegate = self
              
              
              UIApplication.shared.isIdleTimerDisabled = true
              setupCoachingOverlay()
              
        
    }

    func configureGesturesForScene(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(castQueryForObject(touch:)))
        sceneView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc
    func castQueryForObject(touch: UITapGestureRecognizer){

        if let faceAnchor = sceneView.session.currentFrame?.anchors.first as? ARFaceAnchor {
            
//            let blendshape = faceAnchor.blendShapes
//
//            let mouthSmileLeft = blendshape[.mouthSmileLeft]
//            let mouthSmileRight = blendshape[.mouthSmileRight]
//
    
        }
       
        if !TraininSessionView.isHidden {
            TraininSessionView.isHidden = true
        } else {
            
            TraininSessionView.isHidden = false
        }
        
//        let billboardConstraint = SCNBillboardConstraint()
//        billboardConstraint.freeAxes = [.all]
//
//
//
//        let touchPoint = touch.location(in: sceneView)
//        guard let rayquery = sceneView.raycastQuery(from: touchPoint, allowing: .estimatedPlane, alignment: .any) else { return }
//
//
//
//        if let closestResults = sceneView.session.raycast(rayquery).first {
//
//            let anchor = ARAnchor(transform: closestResults.worldTransform)
//            let noteNode = Plane.makeQuestionNode(anchor: anchor)
//         noteNode.constraints = [billboardConstraint]
//
//            sceneView.scene.rootNode.addChildNode(noteNode)
//
//            sceneView.session.add(anchor: anchor)
//
//        }
      
    }
    
    @IBAction func didPressedUnderstood(_ sender: UIButton) {
        startImageCounter()
        
    }
    
    
    func startImageCounter(){
        
        counterTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if self.counter == 3 {
                timer.invalidate()
                self.counter = 0
                self.counterImageSet = self.counterImageSetCopy
                self.startMeming()
                
            }else {
                var presentImage = self.counterImageSet.removeFirst()
                self.imageView.image = UIImage(named: presentImage)
                self.counter = self.counter + 1
                
            }
        })
        
    }
    
    
    func startMeming() {
        memeDataSet.removeAll()
        
        sceneView.session.run(configuration)
        
        let memeCount = memeCollection.count
        if memeCount != 0 {
            let randomNumber = Int.random(in: 0..<memeCount)
            print("RANDOM NUM: \(randomNumber)")
            let memeImage = memeCollection.remove(at: randomNumber)
            print("Current Image: \(memeImage)")
            
            imageView.image = UIImage(named: memeImage)
        } else {
            endMemesession()
        }
    }
    
    func runNextMeme(isFunny: Bool) {
        imageView.image = UIImage(named: "wait")
        uploadToFirebase(isFunny: isFunny) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.startMeming()
            }
        }
    }
    
    func endMemesession(){
        sceneView.session.pause()
        imageView.image = UIImage(named: "thankyou")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.TraininSessionView.isHidden = true
        }
        
        
    }
    
    func uploadToFirebase(isFunny: Bool, completionHandler: ()-> Void){
        var memeData = MemeData(isFunny: isFunny, dataSet: memeDataSet)
        
        print(memeData)
        
        completionHandler()
        
    }
    
    @IBAction func didPressedFunny(_ sender: UIButton) {
        sceneView.session.pause()
        runNextMeme(isFunny: true)
        
    }
    
    @IBAction func didPressedNotFunny(_ sender: UIButton) {
        sceneView.session.pause()
        runNextMeme(isFunny: false)
    }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/

}




// MARK: - ARCSCNDELEGATE
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        if let faceAnchor = anchor as? ARFaceAnchor {
            print("found a face")
        }
        
        
        
        
        
//        if let imageAchor = anchor as? ARImageAnchor {
//            let billboardConstraint = SCNBillboardConstraint()
//            billboardConstraint.freeAxes = [.all]
//            let noteNode = Plane.makeQuestionNode(anchor: imageAchor)
//            noteNode.constraints = [billboardConstraint]
//            node.addChildNode(noteNode)
//        }

//        print("DETECTED IMAGES")
        
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        
//        let plane = Plane(anchor: planeAnchor, in: sceneView)
//
//        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor {
            print("UPDATING FACEANCHOR AGAIN AGAIN AGAIN")

            let blendshape = faceAnchor.blendShapes

            let mouthSmileLeft = blendshape[.mouthSmileLeft]
            let mouthSmileRight = blendshape[.mouthSmileRight]

            print("LEFT MOUTH: \(mouthSmileLeft), RIGHT MOUTH: \(mouthSmileRight)")
            
            let timeStamp = NSDate().timeIntervalSince1970
            
            var frameData = SmileFrame(leftSide: mouthSmileLeft!.doubleValue, rightSide: mouthSmileRight!.doubleValue, time: timeStamp)
            
            memeDataSet.append(frameData)




//            print(blendshape[.jawOpen])
        }
        
//        guard let planeAnchor = anchor as? ARPlaneAnchor,
//        let plane = node.childNodes.first as? Plane
//        else {return}
//
//        if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
//            planeGeometry.update(from: planeAnchor.geometry)
//        }
//
//        if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
//            extentGeometry.width = CGFloat(planeAnchor.extent.x)
//            extentGeometry.height = CGFloat(planeAnchor.extent.z)
//            plane.extentNode.simdPosition = planeAnchor.center
//        }
//
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        if let imageAchor = anchor as? ARImageAnchor {
            
            print("ADDED IMAGE ANCHOR")
//            let billboardConstraint = SCNBillboardConstraint()
//            billboardConstraint.freeAxes = [.all]
            let noteNode = Plane.makeQuestionNode(anchor: imageAchor)
//            noteNode.constraints = [billboardConstraint]

            node.addChildNode(noteNode)
        }
        
        if let faceAnchor = anchor as? ARFaceAnchor {
            print("ADDED A FACE ANCHOR")
            let noteNode = Plane.makeQuestionNode(anchor: faceAnchor)
            node.addChildNode(noteNode)
        }
        
        if let bodyAnchor = anchor as? ARBodyAnchor {
            print("BODY ANCHOR FOUND")
            if let skeleton = bodyAnchor.skeleton.localTransform(for: .rightShoulder) {
                let billboardConstraint = SCNBillboardConstraint()
                billboardConstraint.freeAxes = [.all]
                let someAnchor = ARAnchor(transform: skeleton)
                let noteNode = Plane.makeQuestionNode(anchor: someAnchor)
                noteNode.constraints = [billboardConstraint]
                node.addChildNode(noteNode)
                
//                noteNode.transform = SCNMatrix4(skeleton)
                
                
            }
            
        }

        return node

    }
    
}

    
// MARK: - ARSessionDelegate
extension ViewController: ARSessionDelegate {
    
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        guard let frame = session.currentFrame else { return }
        print("Just added an anchor and felt so good")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
//        print("FRAME IS UPDATED")
        
    }
    
}


//MARK: - COACHING OVERLAY
extension ViewController: ARCoachingOverlayViewDelegate {
    
    func setupCoachingOverlay(){
        
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
                                        coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                        coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                        coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
                                        coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        coachingOverlay.activatesAutomatically = true
        
        coachingOverlay.goal = .anyPlane
        
    }
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //CLEAR UI for the COACHING SESSION
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //unhide the UI as coaching finishes
    }
    
}
