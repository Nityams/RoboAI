//
//  notAdvanced.swift
//  RobotWarsOSX
//
//  Created by Nityam Shrestha on 6/29/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation

//
//  AdvancedRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation

class notAdvanced: Robot {
    
    enum PositionIndex
    {
        case TopLeft, TopRight, BottomLeft, BottomRight, Middle
    }
    
    enum RobotState
    {                    // enum for keeping track of RobotState
        case Default, Turnaround, Firing, Searching, RunAway, RunFire, CamperKill
    }
    
    var currentRobotState: RobotState = .Default {
        didSet {
            actionIndex = 0
        }
    }
    
    var currentPosIndex:PositionIndex? = nil
    
    var actionIndex = 0                 // index in sub-state machines, could use enums
    // but will make harder to quickly add new states
    
    var lastKnownPosition = CGPoint(x: 0, y: 0)
    var lastKnownPositionTimestamp = CGFloat(0.0)
    let firingTimeout = CGFloat(2.0)
    var scanned:Bool = false
    var enemyPos:CGPoint = CGPoint(x: 30, y: 170)
    var noTurn:Bool = true
  
    
    override func run() {
        while true {
            switch currentRobotState {
            case .Default:
                performNextDefaultAction()
            case .Searching:
                performNextSearchingAction()
            case .Firing:
                performNextFiringAction()
            case .RunAway:
                performRunAway()
            case .RunFire:
                performRunFireAction()
            case .CamperKill:
                performNextShootCornerAction()
            case .Turnaround:
                break
            }
        }
    }
    
    func performNextDefaultAction() {
        // uses actionIndex with switch in case you want to expand and add in more actions
        // to your initial state -- first thing robot does before scanning another robot
        switch actionIndex % 1 {          // should be % of number of possible actions
        case 0:
            moveAhead(25)
            shoot()
            currentRobotState = .Searching
        default:
            break
        }
        actionIndex += 1
    }
    
    func performNextSearchingAction() {
        
        // check where we are
        // and shoot by covering areas
        
        let myPos = posIndex()
      //  if(noTurn || myPos == .Middle){
            switch myPos
            {
            case .BottomRight:
                turnRobotRight(45)
                turnToCenter()
                noTurn = false
                break
            case .BottomLeft:
                turnRobotLeft(45)
                turnToCenter()
                noTurn = false
                break
            case .TopLeft:
                turnRobotRight(45)
                turnToCenter()
                noTurn = false
                break
            case .TopRight:
                turnRobotLeft(45)
                turnToCenter()
                noTurn = false
                break
            default:
                noTurn = true
                break;
            //}
        }
        //turnToCenter()
        if(actionIndex % 14 > 0)
        {
            switch actionIndex % 7
            {          // should be % of number of possible actions
            case 0:
                moveAhead(50)
                shoot()
            case 1:
                turnRobotLeft(30)
                shoot()
            case 2:
                moveAhead(65)
                shoot()
            case 3:
                turnRobotRight(30)
                shoot()
            case 4:
                turnRobotLeft(40)
                shoot()
            case 5:
                turnRobotRight(40)
                shoot()
            default:
                shoot()
                break
            }
            actionIndex += 1
        }else
        {
            currentRobotState = .CamperKill
            actionIndex += 1
        }
    }
    
    func performNextShootCornerAction() {
        var angle:Int;
        switch actionIndex
        {
        case 1 :
            //TopRight
            angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(CGPoint(x: arenaDimensions().width, y: arenaDimensions().height)))
            if angle < 0
            {
                turnGunLeft(abs(angle))
            }
            else
            {
                turnGunRight(angle)
            }
            shoot()
            shoot()
            if self.posIndex() == .BottomRight
            {
                turnRobotLeft(8)
                shoot()
            }
            
            break;
        case 2 :
            // TopLeft
            angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(CGPoint(x: 0, y: arenaDimensions().height)))
            if angle < 0 {
                turnGunLeft(abs(angle))
            } else {
                turnGunRight(angle)
            }
            shoot()
            shoot()
            if posIndex() == .BottomLeft
            {
                turnRobotRight(8)
                shoot()
            }
            
        case 3 :
            angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(CGPoint(x: 0, y: 0)))
            if angle < 0 {
                turnGunLeft(abs(angle))
            } else {
                turnGunRight(angle)
            }
            shoot()
            shoot()
            if posIndex() == .TopLeft
            {
                turnRobotLeft(8)
                shoot()
            }
        case 4:
            angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(CGPoint(x: arenaDimensions().width, y: 0)))
            if angle < 0 {
                turnGunLeft(abs(angle))
            } else {
                turnGunRight(angle)
            }
            shoot()
            shoot()
            if posIndex() == .TopRight
            {
                turnRobotRight(8)
                shoot()
            }
            
        default:
            currentRobotState = .Searching
        }
        actionIndex += 1
    }
    
    func turnToCenter() {
        let arenaSize = arenaDimensions()
        let angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(CGPoint(x: arenaSize.width/2, y: arenaSize.height/2)))
        if angle < 0 {
            turnGunLeft(abs(angle))
        } else {
            turnGunRight(angle)
        }
    }
    func bodyToCenter(){
        let arenaSize = arenaDimensions()
        let angle = Int(angleBetweenHeadingDirectionAndWorldPosition(CGPoint(x: arenaSize.width/2, y: arenaSize.height/2)))
        if angle < 0 {
            turnRobotLeft(abs(angle))
        } else {
            turnRobotRight(angle)
        }
        
    }
    
    func goToCenter(){
        //turnToCenter()
        bodyToCenter()
        moveAhead(200)
        
    }
    
    func posIndex() -> PositionIndex {
        if position().y < arenaDimensions().height/2
        {
            if position().x < arenaDimensions().width/2
            {
                return .BottomLeft
            }
            else
            {
                return .BottomRight
            }
        }else if position().y > arenaDimensions().height/2
        {
            if position().x < arenaDimensions().width/2
            {
                return .TopLeft
            }
            else
            {
                return .TopRight
            }
        }
        else
        {return .Middle}
    }
    
    
    func performRunFireAction() {
        let angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(enemyPos))
        if angle >= 0 {
            turnGunRight(abs(angle))
        } else {
            turnGunLeft(abs(angle))
        }
        shoot()
        shoot()
        
    }
    override func bulletHitEnemy(bullet: Bullet!) {
        // unimplemented but could be powerful to use this...
        //lastKnownPosition = bullet.position;
        print(currentRobotState)
        cancelActiveAction()

        enemyPos = bullet.position
       // scannedRobot(nil, atPosition: bullet.position)
        if currentRobotState != .RunAway
        {
            if currentRobotState != .Firing
            {
                cancelActiveAction()
            }
            
            scanned = false
            lastKnownPosition = enemyPos
            lastKnownPositionTimestamp = currentTimestamp() + 1
            currentRobotState = .Firing
        }
        print("Enemy got hit now calling .Firing state")
    
    }
    
    
    override func scannedRobot(robot: Robot!, atPosition position: CGPoint) {
       robot.cancelActiveAction()
        if currentRobotState != .RunAway
        {
            if currentRobotState != .Firing
            {
                cancelActiveAction()
            }
            
            scanned = true
            lastKnownPosition = position
            lastKnownPositionTimestamp = currentTimestamp()
            currentRobotState = .Firing
        }
    }
    
    func performNextFiringAction() {
        if currentTimestamp() - lastKnownPositionTimestamp > firingTimeout {
            currentRobotState = .Searching
        } else {
            let angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(lastKnownPosition))
            if angle >= 0 {
                turnGunRight(abs(angle))
            } else {
                turnGunLeft(abs(angle))
            }
//            if(scanned != true)
//            {//body turn
//                turnRobotRight(<#T##degrees: Int##Int#>)
//                moveAhead(20)
//            }
            shoot()
            
        }
    }
    
    override func hitWall(hitDirection: RobotWallHitDirection, hitAngle angle: CGFloat) {
        cancelActiveAction()
        // goToCenter()
        
        let previousState = currentRobotState
        currentRobotState = .Turnaround
        
      //  print("hitwall \(position())")
        // leave wall
        goToCenter()
        moveAhead(113)
        
        // reset to old state
        currentRobotState = previousState
    }
    
    override func gotHit() {
        // unimplemented
        print("aaaaahhhh, got hit")
        currentRobotState = .RunAway
    }
    
    func performRunAway()
    {
        print("Runnning aaway from \(currentRobotState)")
        if currentRobotState == .Firing || currentRobotState == .Searching || currentRobotState == .CamperKill
        {
            print("firing canceld and running away")
            cancelActiveAction()
        }
        print("got hit in the function")
        
        if scanned
        {
            moveBack(500)
            //  turnRobotLeft(180)
            shoot()
            shoot()
            shoot()
            scanned = false
            currentRobotState = .Firing
        }
        else
        {
            moveAhead(500)
            turnRobotLeft(45)
            moveAhead(100)
            currentRobotState = .Firing
        }
    }
    
    
}