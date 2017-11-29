//
//  ViewController.swift
//  ArDicee
//
//  Created by Guillaume BLONDEAU on 23/11/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        if let touch = touches.first
        {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first
            {
                addDice(atLocation: hitResult)
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult)
    {
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true)
        {
            diceNode.position = SCNVector3(x: location.worldTransform.columns.3.x,
                                           y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                           z: location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(dice: diceNode)
        }
    }
    
    func roll(dice: SCNNode)
    {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5),
                                              y: 0,
                                              z: CGFloat(randomZ * 5),
                                              duration: 0.5))
    }
    
    func rollAll()
    {
        if (!diceArray.isEmpty)
        {
            for dice in diceArray
            {
                roll(dice: dice)
            }
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem)
    {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem)
    {
        if (!diceArray.isEmpty)
        {
            for dice in diceArray
            {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?)
    {
        rollAll()
    }
    
    //MARK: - ARSCNViewDelegate Methods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    
    //MARK: - Plane rendering methods
    
    func createPlane(withPlaneAnchor anchor: ARPlaneAnchor) -> SCNNode
    {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let planeNode = SCNNode()
        let gridMateriel = SCNMaterial()

        planeNode.position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        gridMateriel.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMateriel]
        planeNode.geometry = plane
        return planeNode
    }

}
