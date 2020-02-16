//
//  GameViewController.swift
//  SpaceBizingo
//
//  Created by Gabriela Bezerra on 1/29/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    //MARK: - View Outlets
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var stateMessageLabel: UILabel!
    
    //MARK: - Custom Alert
    lazy var stateAlert: UIAlertController = {
        let alert = UIAlertController(title: state.rawValue, message: nil, preferredStyle: .alert)
        return alert
    }()
    
    //MARK: - Socket Service Instatiation
    let socketService: SocketService = SocketService()
    
    //MARK: - GameState
    var state: GameState! {
        didSet {
            switch state {
            case .yourTurn:
                dismissStateAlert()
            default:
                showStateAlert()
            }
        }
    }
    
    //MARK: - GameScene Cast
    var gameScene: GameScene {
        return skView.scene as! GameScene
    }
    
    //MARK: - View Actions
    @IBAction func sendAction(_ sender: UIButton) {
        if playerIsConnected() {
            if let content = self.textField.text, content.replacingOccurrences(of: " ", with: "") != "" {
                socketService.sendMessage(author: socketService.name!, content: content)
                self.view.endEditing(true)
            }
        }
    }
    
    @IBAction func optionsAction(_ sender: Any) {
        if playerIsConnected() {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let resignAction = UIAlertAction(title: "Resign", style: .destructive, handler: { (alert) in
                //resign handler
            })
            
            let endTurnAction = UIAlertAction(title: "End Turn", style: .default, handler: { (alert) in
                //endTurn handler
                if let originIndex = self.gameScene.board.getSelectedTriangle()?.data.index {
                    self.socketService.move(from: originIndex, to: Index(row: 0, column: 0))
                }
            })
            
            let restartAction = UIAlertAction(title: "Request Restart Match", style: .destructive, handler: { (alert) in
                //restart handler
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(endTurnAction)
            actionSheet.addAction(restartAction)
            actionSheet.addAction(resignAction)
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true)
            
        }
    }
    
    
    //MARK: - Connection Status Verification
    func playerIsConnected() -> Bool {
        if gameScene.player == .disconnected {
            showAlert(text: "Server is Offline", buttonText: "Try Again") { alert in
                self.socketService.socket.connect()
            }
            return false
        }
        return true
    }
    
    func showAlert(text: String, buttonText: String = "OK", handler: @escaping (UIAlertAction) -> Void = { alert in }) {
        let alertController = UIAlertController(title: text, message: "", preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(title: buttonText, style: .default, handler: handler)
        )
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - State Alert
    func showStateAlert() {
        self.present(stateAlert, animated: true, completion: nil)
    }
    
    func dismissStateAlert() {
        stateAlert.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - GameViewController default Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatTextView.layoutManager.allowsNonContiguousLayout = false
        self.chatTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: -20, right: 10);
        
        self.textField.delegate = self
        
        socketService.delegate = self
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                sceneNode.backgroundColor = self.view.backgroundColor!
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                skView.presentScene(sceneNode)
                
                skView.ignoresSiblingOrder = true
                
                skView.showsFPS = true
                skView.showsNodeCount = true
                
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK: - TextFieldDelegate
extension GameViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let offsetY = UIScreen.main.bounds.height/2.55 - textField.frame.origin.y
        UIView.animate(withDuration: 0.25) {
            self.view.layer.position = CGPoint(x: self.view.layer.position.x, y: self.view.layer.position.y - offsetY)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.view.layer.position = CGPoint(x: self.view.layer.position.x, y: UIScreen.main.bounds.height/2)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}


//MARK: - GameDelegate
extension GameViewController: GameDelegate {
    
    func didStart() {
        if gameScene.player == .pointBottom {
            state = .yourTurn
        } else {
            state = .waiting
        }
    }
    
    func newTurn(_ name: String) {
        if name == gameScene.player.rawValue {
            state = .yourTurn
        } else {
            state = .waiting
        }
    }
    
    func playerDidMove(_ name: String, from originIndex: Index, to newIndex: Index) {
        
    }
    
    func didWin(_ name: String) {
        
    }
    
    func receivedMessage(_ name: String, msg: String) {
        //let string = "\n\(name): \(msg)"

        let mutAtt = NSMutableAttributedString(attributedString: chatTextView.attributedText)
        let attString = NSMutableAttributedString()
            .bold("\(name.capitalized): ")
            .normal("\(msg)\n")
        mutAtt.insert(attString, at: mutAtt.length-1)
        self.chatTextView.attributedText = mutAtt
       
        let stringLength: Int = self.chatTextView.text.count
        let range = NSMakeRange(stringLength-1, 1)
        self.chatTextView.scrollRangeToVisible(range)
    }
    
    func youArePlayingAt(_ team: String) {
        gameScene.player = Player(rawValue: team) ?? .disconnected
        print("👾 You are player \(gameScene.player.rawValue)")
    }
    
}

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 14 }
    var boldFont:UIFont { return UIFont(name: "Helvetica-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont(name: "Helvetica-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}

    func bold(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func normal(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func blackHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func underlined(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
