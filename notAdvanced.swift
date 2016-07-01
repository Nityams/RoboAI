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
    
    enum PositionIndex{
        case TopLeft, TopRight, BottomLeft, BottomRight, Middle
    }
    
    enum RobotState {                    // enum for keeping track of RobotState
        case Default, Turnaround, Firing, Searching, RunAway, RunFire
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
    var hp:Int = 0
    
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
                performRunAway()// ignore Turnaround since handled in hitWall
            case .RunFire:
                performRunFireAction()
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
        if(noTurn || myPos == .Middle){
            switch myPos
            {
            case .BottomRight:
                turnRobotRight(45)
                noTurn = false
                break
            case .BottomLeft:
                turnRobotLeft(45)
                noTurn = false
                break
            case .TopLeft:
                turnRobotRight(45)
                noTurn = false
                break
            case .TopRight:
                turnRobotLeft(45)
                noTurn = false
                break
            default:
                noTurn = true
                break;
            }
        }
        //turnToCenter()
        
        if(hp > 6)
        {
            turnRobotLeft(180)
            hp = 0
        }
        switch actionIndex % 6 {          // should be % of number of possible actions
        case 0:
            moveAhead(50)
            shoot()
        case 1:
            turnRobotLeft(30)
            shoot()
        case 2:
            moveAhead(50)
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
        hp += 1
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
        moveAhead(20)
        
    }
    
    func posIndex() -> PositionIndex {
        if position().y < arenaDimensions().height/2 - 10
        {
            if position().x < arenaDimensions().width/2
            {
                return .BottomLeft
            }
            else
            {
                    return .BottomRight
            }
        }else if position().y > arenaDimensions().height/2 + 10
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
            shoot()
        }
    }
    func performRunFireAction() {
            let angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(enemyPos))
            if angle >= 0 {
                turnGunRight(abs(angle))
            } else {
                turnGunLeft(abs(angle))
            }
            shoot()
        
    }
    override func bulletHitEnemy(bullet: Bullet!) {
        // unimplemented but could be powerful to use this...
        //lastKnownPosition = bullet.position;
        hp = 0;
        enemyPos = bullet.position
        scannedRobot(nil, atPosition: bullet.position)
        
        
    }

    
    override func scannedRobot(robot: Robot!, atPosition position: CGPoint) {
       print("scanned")
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
    
    override func gotHit() {
        // unimplemented
        print("got hit")
        currentRobotState = .RunAway
        
    }
    
    func performRunAway()
    {
        if currentRobotState == .Firing || currentRobotState == .Searching
        {
            print("firing canceld and running away")
            cancelActiveAction()
           // let turn = gunHeadingDirection() - headingDirection()
        }
        
        print("got hit")
        
        if scanned{
            moveBack(900)
          //  turnRobotLeft(180)
            shoot()
            shoot()
            shoot()
             scanned = false
            currentRobotState = .Firing
        }
        moveAhead(900)
        turnRobotLeft(45)
        moveAhead(40)
        currentRobotState = .Firing
    }
    override func hitWall(hitDirection: RobotWallHitDirection, hitAngle angle: CGFloat) {
        cancelActiveAction()
       // goToCenter()
        
        let previousState = currentRobotState
        currentRobotState = .Turnaround
       
        print("hitwall \(position())")
        print("wall hit here")
        // leave wall
        goToCenter()
        //moveAhead(60)
        
        // reset to old state
        currentRobotState = previousState
            
    }
    
    
}