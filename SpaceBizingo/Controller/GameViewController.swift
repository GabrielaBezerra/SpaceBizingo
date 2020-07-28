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
    lazy var stateView: UIView = {
        let view = UIView(frame: self.skView.frame)
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        return view
    }()
    
    private lazy var createOrEnterAlert: UIAlertController = {
        let alert = UIAlertController(title: "Welcome to Green Bizingo", message: "", preferredStyle: .alert)
        
        let enterAction = UIAlertAction(title: "Enter Room", style: .default) { [unowned self] (action) in
            self.present(self.enterRoomPromptAlert, animated: true, completion: nil)
        }
        
        let createAction = UIAlertAction(title: "Create Room", style: .default) { [unowned self]( action) in
            self.present(self.createRoomAlert, animated: true, completion: nil)
        }
        
        alert.addAction(createAction)
        alert.addAction(enterAction)
        
        return alert
    }()
    
    private lazy var createRoomAlert: UIAlertController = {
        let alert = UIAlertController(title: "Your Code is: \(GRPCWrapper.shared.server.addressDescription)", message: "Send this code to the player you want to invite to your room.", preferredStyle: .alert)
        return alert
    }()
    
    private lazy var enterRoomPromptAlert: UIAlertController = {
        let alert = UIAlertController(title: "Insert address:port to Connect", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "insert port"
            textField.keyboardType = .default
        }
        
        let connectAction = UIAlertAction(title: "Connect", style: .default) { (action) in
            guard let text = alert.textFields?.first?.text else {
                    print("🔥 No port was detected on connection prompt alert")
                    return
            }
            
            GRPCWrapper.shared.runner.run(addressAndPort: text, delegate: self, handler: { serverIP, serverPort in
                GRPCWrapper.shared.connectTo(ip: serverIP, port: serverPort) { (success, description) in
                    print("connectToReply handler callback", success ?? "nil", description ?? "nil")
                        self.youArePlayingAt("top")
                        self.didStart()
                }
            })
        }
        
        alert.addAction(connectAction)
        
        return alert
    }()
    
    //MARK: - Socket Service Instatiation
    let socketService: NetworkLayer = NetworkLayer()
    
    //MARK: - GameState
    var state: GameState! = .awaitingConnection {
        didSet {
            
            self.stateMessageLabel.text = self.state.rawValue
            switch state {
            case .yourTurn:
                dismissStateView()
            default:
                showStateView()
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
                self.textField.text?.removeAll()
                self.view.endEditing(true)
            }
        }
    }
    
    @IBAction func optionsAction(_ sender: Any) {
        if playerIsConnected() {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let endTurnAction = UIAlertAction(title: "End Turn", style: .default, handler: { (alert) in
                //endTurn handler
                if self.gameScene.board.hasMoved {
                    self.socketService.move(from: self.gameScene.board.previousPos!, to: self.gameScene.board.newPos!)
                    return
                } else {
                    let alert = UIAlertController(title: "Cannot skip move!", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
            let resignAction = UIAlertAction(title: "Resign", style: .destructive) { (alert) in
                let opponent = self.gameScene.player == .pointBottom ? Player.pointTop : Player.pointBottom
                self.gameScene.board.delegate.gameOver(winner: opponent)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(endTurnAction)
            actionSheet.addAction(resignAction)
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true)
            
        }
    }
    
    
    //MARK: - Connection Status Verification
    func playerIsConnected() -> Bool {
        if gameScene.player == .disconnected {
            showAlert(text: "Server is Unavailable", buttonText: "Try Again") { alert in
//                self.socketService.socket.connect()
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
    
    //MARK: - State View
    func showStateView() {
        self.view.addSubview(stateView)
    }
    
    func dismissStateView() {
        stateView.removeFromSuperview()
    }
    
    //MARK: - GameViewController default Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stateMessageLabel.text = GameState.awaitingConnection.rawValue
        
        self.chatTextView.layoutManager.allowsNonContiguousLayout = false
        self.chatTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: -20, right: 10);
        
        self.textField.delegate = self
        
        socketService.delegate = self
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                sceneNode.board.delegate = self
                
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showStateView()
        self.present(self.createOrEnterAlert, animated: true, completion: nil)
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
    
    //MARK: - Restart
    func restart() {
        socketService.restart()
        viewDidLoad()
        viewDidAppear(true)
        self.chatTextView.text = "\n"
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
        if self.gameScene.player == .pointBottom {
            self.state = .yourTurn
            self.createRoomAlert.dismiss(animated: true, completion: nil)
        } else {
            self.state = .waiting
        }
    }
    
    func newTurn(_ name: String) {
        
        self.gameScene.board.verifyDeadPieces()
        
        self.gameScene.board.hasMoved = false
        self.gameScene.board.newPos = nil
        self.gameScene.board.previousPos = nil
        
        if name == gameScene.player.rawValue {
            state = .yourTurn
        } else {
            state = .waiting
        }
    }
    
    func playerDidMove(_ name: String, from originIndex: Index, to newIndex: Index) {
        gameScene.board.movePiece(from: originIndex, to: newIndex)
    }
    
    func didWin() {
        let alert = UIAlertController(title: "You Win", message: "", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Play Again", style: .default, handler: { _ in self.restart() })
        alert.addAction(exit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didLose() {
        let alert = UIAlertController(title: "You Lose", message: "", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Play Again", style: .default, handler: { _ in self.restart() })
        alert.addAction(exit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func receivedMessage(_ name: String, msg: String) {

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
        self.gameScene.player = Player(rawValue: team) ?? .disconnected
        
        print("👾 You are player \(self.gameScene.player.rawValue)")
        
        self.playerNameLabel.text = "You are Team "+self.gameScene.player.rawValue.capitalized
    }
    
}


extension GameViewController: BoardDelegate {
    
    func gameOver(winner: Player) {
        socketService.gameOver(winner: winner)
    }
    
}
