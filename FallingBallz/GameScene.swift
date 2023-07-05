import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var obstacleNumber : Int = 0
    var scoreLabel: SKLabelNode!
    let categoryA: UInt32 = 0x1 << 0 // 카테고리 A
    let categoryB: UInt32 = 0x1 << 1 // 카테고리 B
    
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self

        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0.5
        self.physicsBody = borderBody

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: -130, y: 550)
        
        addChild(scoreLabel)
    }
    
    // 누르면 볼이 향할 방향 나타내기 해야함
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //클릭하면 노드카운트 줄이기
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // 터치된 노드를 찾습니다.
        let touchedNode = self.atPoint(touchLocation)
        
        
        // 터치된 노드가 `obstacle`인지 확인하고, nodeCount를 줄입니다.
        if let obstacleNode = touchedNode as? SKSpriteNode, obstacleNode.name?.hasPrefix("obstacle") == true {
            decreaseNodeCount(obstacleNode)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let randomObsacleNumber = Int.random(in: 1...2)
        let positions = checkInterNode(numOfNodes: randomObsacleNumber)
//        var tmpArr: [Int] = [0,0,0]
//        var cnt = 0
//
        
        makeBall()

        for xPos in positions {
            makeObstacle(xPos: xPos)

        }
        
                
      //  print(tmpArr)
        
        self.enumerateChildNodes(withName: "//obstacle*") { (node, stop) in
            node.run(SKAction.moveBy(x: 0, y: self.frame.size.height * 0.11, duration: 0.1))
            if node.position.y > -800 + self.frame.size.height * 0.11 * 8 {
                node.removeFromParent()
            }
        }
    }
    
    func checkInterNode(numOfNodes: Int) -> [CGFloat] {
        var positions: [CGFloat] = []
        let nodeInterSize = frame.size.width * 0.15
        
        for _ in 0..<numOfNodes {
            print(numOfNodes)
            var isValid = false
            var randomX: CGFloat!
            
            // while !isValid
            repeat {
                randomX = CGFloat.random(in: -280...280)
                //print("\(String(describing: randomX))-----randommmm")
                
                isValid = positions.allSatisfy { xPos in
                    let leftside = xPos-nodeInterSize > randomX+nodeInterSize
                    let rightside = xPos+nodeInterSize < randomX-nodeInterSize
                    return leftside || rightside
                }
            } while !isValid
            positions.append(randomX)
            print(positions)
        }
        return positions
    }
    
    
    func decreaseNodeCount(_ obstacleNode: SKSpriteNode) {
        // obstacleNode에서 countLabel을 찾습니다.
        if let countNode = obstacleNode.childNode(withName: "countLabel") as? SKLabelNode {
            // 현재 nodeCount를 가져옵니다.
            if let countText = countNode.text, let count = Int(countText) {
                // nodeCount를 1씩 감소시키고, 0보다 작으면 노드를 제거합니다.
                let newCount = count - 1
                if newCount > 0 {
                    countNode.text = "\(newCount)"
                } else {
                    obstacleNode.removeFromParent()
                    self.score += 1
                }
            }
        }
    }
    
    
    func randomHuddle() -> String {
        let randomShape = Int.random(in: 0...2)
        let shapeName: String
        
        switch randomShape {
        case 0:
            shapeName = "Triangle"
        case 1:
            shapeName = "Circle"
        case 2:
            shapeName = "Rectangle"
        default:
            shapeName = "Circle"
        }
        return shapeName
    }
    
    // MARK: - 장애물생성
    func makeObstacle(xPos: CGFloat) -> Int {
      
        let randomShape = randomHuddle()
        let obstacle = SKSpriteNode(imageNamed: "\(randomShape)")
        obstacle.size = CGSize(width: frame.size.width * 0.15 , height: frame.size
            .height * 0.08)
        
        obstacle.position = CGPoint(x: xPos, y: -600)
        obstacle.name = "obstacle\(obstacleNumber)"
        obstacleNumber += 1
        
        //physics
        let obstaclePadding = SKPhysicsBody(rectangleOf: CGSize(width: obstacle.size.width + 50 , height: obstacle.size.height + 10 ))
        obstacle.physicsBody = obstaclePadding
        obstacle.physicsBody!.friction = 0.0
        obstacle.physicsBody!.isDynamic = false
        obstacle.physicsBody!.allowsRotation = false
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.zPosition = 1
        obstacle.physicsBody?.categoryBitMask = categoryA
        obstacle.physicsBody?.collisionBitMask = categoryB
        
        //count 추가
        let labelNode = addCount()
        guard let nodeCnt = Int(labelNode.text!) else { return 0 }
        
        obstacle.addChild(labelNode)
        self.addChild(obstacle)
        
        let heightScale = frame.size.height * 0.11
        
        obstacle.run(SKAction.moveBy(x: 0, y: heightScale, duration: 0.1))
        
        return nodeCnt
    }
    
    func makeBall() {
        //원모양의 노드를 만들려면 shape노드를 써야함
        let ball = SKSpriteNode(color: SKColor.white, size: CGSize(width: 20, height:20))
        ball.position = CGPoint(x:0, y: 600)
        
        let ballPhysics = SKPhysicsBody(circleOfRadius: 10)
        ball.physicsBody = ballPhysics

        ballPhysics.friction = 0.0
        ballPhysics.isDynamic = true
        ballPhysics.affectedByGravity = true
        ballPhysics.categoryBitMask = categoryB
        ballPhysics.collisionBitMask = categoryA
        ballPhysics.isDynamic = true // 물리적 시뮬레이션에 응답
        ballPhysics.restitution = 1 // 튕겨나가는 정도 설정
        self.addChild(ball)
        
    }
    
    
    func addCount() -> SKLabelNode {
        let nodeCount: Int
        
        switch score {
        case 0...5:
            nodeCount = Int.random(in: 1...2)
        case 6...10:
            nodeCount = Int.random(in: 2...4)
        case 11...20:
            nodeCount = Int.random(in: 4...6)
        case 21...40:
            nodeCount = Int.random(in: 7...10)
        default:
            nodeCount = Int.random(in: score/5 - 2 ... score/5 + 3)
        }
        let labelNode = SKLabelNode(text: "\(nodeCount)")
        labelNode.name = "countLabel"
        labelNode.fontColor = UIColor.black
        labelNode.fontSize = 40
        labelNode.fontName = "SFUI-Regular"
        labelNode.position = CGPoint(x: -2, y: -18)
        labelNode.zPosition = 2
        
        return labelNode
    }
    
}
