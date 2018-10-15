//
//  ViewController.swift
//  ARDrawing
//
//  Created by Yacha Toueg on 10/14/18.
//  Copyright © 2018 Yacha Toueg. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // THE RESET FUNCTION WILL ALLOW US TO ERASE THE DRAWWING AND START A NEW ONE WITH A NEW CAMERA VIEW
    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    func restartSession(){
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes {(node,_)in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration,options: [.resetTracking, .removeExistingAnchors
            ])
    }

    @IBOutlet weak var draw: UIButton!
    // STEP 1 SET THE RENDER SCENE DELEGATE
    // STEP 2 SET THE CAMERA POSITION! (we need to get the current position of the camera relative to the real world)
    // STEP 3 DRAWING

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        // if self.sceneView.showsStatistics = true, then the scene view will show frame per second and rendering performance.
        self.sceneView.session.run(configuration)
        // for a delegate function to be called when the scene is rendered, you need to decalre the scene view delegate to be self by writing
        self.sceneView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    // this function gets called every time the view is about the render a scene
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        print("rendering")
        // the pointofview contains the current location and orientation of the camera view. It is crucial to grab both the position of the camera as well as the orientation vector which points to the normal of the camera. By adding the two SCNVector types, you will be adding a node in the front of the camera
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        //transform.m31 --> column 3, row 1 from the matrix
        let orientation =  SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        // with the above code, we have obtained the current position vector of the phone, and the orientation vector pointing in the direction of the camera. Now, we must combine these two vectors to be able to add nodes in front of the camera view. we need to create a function "+" seen below
        let currentPositionOfCamera = orientation + location
        DispatchQueue.main.async {
               if self.draw.isHighlighted {print("draw button is being pressed")
                let sphereNode =  SCNNode(geometry: SCNSphere(radius:0.02 ))
                sphereNode.position = currentPositionOfCamera
                // let's add the sphere to the sceneview
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            } else {
                let pointer = SCNNode(geometry: SCNBox(width:0.01, height:0.01, length:0.01, chamferRadius: 0.01/2))
                pointer.position = currentPositionOfCamera
                //we need to keep only one pointer visible! otherwise the user will see many pointers
                
                self.sceneView.scene.rootNode.enumerateChildNodes({(node, _) in
                    
                    //if node geometry is a box, then remove that node () 
                    if node.geometry is SCNBox {
                        node.removeFromParentNode()}
                    
                })
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            }
        }
        

        //SUMMARY OF THE RENDER FUNCTION: When the delegate function gets called, you're getting the current position of the camera. And in that position if the button is being pressed (the draw button), you're putting a sphere node in that position. So if you keep doing that, if you keep putting a sphere for every position in every scene that is being rendered, eventually you will form a line of spheres which makes it look like you're drawing something!
    }

}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y , left.z + right.z)
}
