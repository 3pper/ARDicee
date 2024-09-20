//
//  ViewController.swift
//  ARDicee
//
//  Created by Egor on 26.06.2024.
//

import UIKit
import SceneKit
import ARKit
import Foundation

class ViewController: UIViewController, ARSCNViewDelegate {

    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // showing debug options
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        
//        let sphere = SCNSphere(radius: 0.2)
//        
//        let material = SCNMaterial()
//        
//        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
//        
//        sphere.materials = [material]
//        
//        let node = SCNNode()
//        
//        node.position = SCNVector3(0, 0.1, -0.5)
//        
//        node.geometry = sphere
//        
//        sceneView.scene.rootNode.addChildNode(node)
//        
//        sceneView.autoenablesDefaultLighting = true
        

        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //if need to know about supported your device or no
        //ARWorldTrackingConfiguration.isSupported
        
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    //MARK: - Dice rendering methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal) {
                let results = sceneView.session.raycast(query)
                if let hitResults = results.first {
                   addDice(atLocation: hitResults)
                }
            }
        }
    }
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * Float.pi/2
        let randomZ = Float(arc4random_uniform(4) + 1) * Float.pi/2
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5))
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    func addDice(atLocation location: ARRaycastResult) {
        //Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {

            diceNode.position = SCNVector3(
                location.worldTransform.columns.3.x,
                location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                location.worldTransform.columns.3.z)

            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
            
        }
    }
    
    
    //MARK: - ARSCNViewDelegateMetods

    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
        
    }
    
    //MARK: - Plane rendering methods
    
    func createPlane(withPlaneAnchor planeAnchor : ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let grideMaterial = SCNMaterial()
        
        grideMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [grideMaterial]
        
        planeNode.geometry = plane
        
        
        
        print("detected")
        
        return planeNode
    }

}

