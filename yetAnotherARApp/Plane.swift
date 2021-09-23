//
//  Plane.swift
//  yetAnotherARApp
//
//  Created by HECTOR TERRERO on 6/15/21.
//

import ARKit


extension UIColor {
    static let planeColor = UIColor(named: "planeColor")!
    
}


class Plane: SCNNode {
    
    let meshNode: SCNNode
    let extentNode: SCNNode
    var classificationNode: SCNNode?
    
    
    init(anchor: ARPlaneAnchor, in sceneView: ARSCNView) {
        
        //MESH POLYGON
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!) else { fatalError("cant create palne geometry") }
        
        meshGeometry.update(from: anchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        
        
        //RECTANGLE PLANE
        
        let extentPlane: SCNPlane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        extentNode = SCNNode(geometry: extentPlane)
        extentNode.simdPosition = anchor.center
        
        
        extentNode.eulerAngles.x = -.pi / 2
        
        
        super.init()
        
//        let textNode = Plane.makeQuestionNode()
        
        
        addChildNode(meshNode)
        addChildNode(extentNode)
        
      
//        classificationNode = textNode
//
//        extentNode.addChildNode(textNode)
        
        setupMeshVisualStyle()
        setupExtentVisualStyle()
        
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupMeshVisualStyle() {
        
        meshNode.opacity = 0.25
        
        guard let material = meshNode.geometry?.firstMaterial else {return}
        material.diffuse.contents = UIColor.planeColor
        
    }
    
    func setupExtentVisualStyle() {
        extentNode.opacity = 0.6
        
        guard let material = extentNode.geometry?.firstMaterial else {return}
        
        material.diffuse.contents = UIColor.planeColor
        
    }
    
    static func makeQuestionNode(anchor: ARAnchor) -> SCNNode {
        let Questions = ["How Old are you", "Are you taller than allegetor", "Do you like Cesar Flawless hair?", "Is Rafael Quapo?"]
        
        let questionNumber = Int.random(in: 0...3)
        let question = Questions[questionNumber]
        
        let textGeometry = SCNText(string: question, extrusionDepth: 10)
        textGeometry.font = UIFont(name: "Futura", size: 30)
        
        if let material = textGeometry.firstMaterial {
            material.diffuse.contents = UIColor.black
        }
    
        
        let textNode = SCNNode(geometry: textGeometry)
        
        textNode.simdTransform = anchor.transform
        
        textNode.simdScale = float3(0.002)
        
        return textNode
        
    }
    
    
    
    
    
    
}
