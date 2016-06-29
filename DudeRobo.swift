//
//  AdvancedRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation

class DudeRobo: Robot {
    
    enum RobotState {                    // enum for keeping track of RobotState
        case KillMode, Turnaround, Firing, RunAway
    }
    
    var currentRobotState: RobotState = .KillMode {
        didSet {
            actionIndex = 0
        }
    }
    var actionIndex = 0                 // index in sub-state machines, could use enums
    // but will make harder to quickly add new states
    
    var lastKnownPosition = CGPoint(x: 0, y: 0)
    var lastKnownPositionTimestamp = CGFloat(0.0)
    let firingTimeout = CGFloat(1.0)
    let gunToleranceAngle = CGFloat(2.0)
    let bottonCorner:CGPoint = CGPoint(x: 0, y: 0)
  
    //compare hitpoints for shootout
    
    override func run() {
        while true {
            switch currentRobotState {
            case .KillMode:
                performNextKillModeAction()
            case .RunAway:
                performNextRunawayAction()
            case .Firing:
                performNextFiringAction()
            case .Turnaround:               // ignore Turnaround since handled in hitWall
                break
            }
        }
    }
    
    func performNextKillModeAction() {
        // uses actionIndex with switch in case you want to expand and add in more actions
        // to your initial state -- first thing robot does before scanning another robot
        switch actionIndex % 1 {          // should be % of number of possible actions
        case 0:
            shoot()
            turnGunLeft(10)
            shoot()
            turnGunLeft(10)
            shoot()
            turnGunLeft(10)
            shoot()
            turnGunRight(40)
            shoot()
            turnGunRight(10)
            shoot()
            turnGunRight(10)
            shoot()
            turnGunLeft(30)
            shoot()
            moveAhead(100)
            turnRobotLeft(180)
            shoot()
            turnGunLeft(10)
            shoot()
            turnGunLeft(10)
            shoot()
            turnGunLeft(10)
            shoot()
            turnGunRight(40)
            shoot()
            turnGunRight(10)
            shoot()
            turnGunRight(10)
            shoot()
            turnGunLeft(30)
            shoot()
        default:
            break
        }
        //actionIndex += 1
    }
//    func turnMe(angle: Int)
//    {
//        turnRobotRight(angle)
//    }
    
    func performNextRunawayAction() {
        switch actionIndex % 3 {          // should be % of number of possible actions
        case 0:
            moveAhead(50)
            turnRobotLeft(60)
            actionIndex = 0
            shoot()
        case 1:
            turnRobotLeft(20)
            moveAhead(60)
            actionIndex = 0
            shoot()
        case 2:
            moveAhead(50)
            moveAhead(60)
            turnRobotRight(60)
            actionIndex = 0
            shoot()
        case 3:
            turnRobotRight(20)
            moveAhead(60)
            actionIndex = 0
            shoot()
        default:
            break
        }
//        actionIndex += 1
    }
    
    func performNextFiringAction() {
        if currentTimestamp() - lastKnownPositionTimestamp > firingTimeout {
            currentRobotState = .RunAway
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
    
    override func scannedRobot(robot: Robot!, atPosition position: CGPoint) {
//        if currentRobotState != .Firing {
//            cancelActiveAction()
//        }
//        
//        lastKnownPosition = position
//        lastKnownPositionTimestamp = currentTimestamp()
//        currentRobotState = .Firing
        
        turnToEnemyPosition(position)
        actionIndex = 3
    }
    
    override func gotHit() {
        // unimplemented
        print("Hit hit hit")
        if currentRobotState != .Turnaround
        {
        cancelActiveAction()
        print("canceled and turned around instantiated")
        
        let maxHeight = arenaDimensions().height;
        let maxWidth = arenaDimensions().width;
        let posX = position().x
        let posY = position().y
        let total = (maxHeight - posY) + (maxWidth - posX)
        let totalPos = position().x + position().y
//        var posAll = CGPoint(x: maxWidth - posX, y: maxHeight - posY)

        
        print("got Hit")
        if total < totalPos
        {
                goHere(0)
        }else{
            goHere(Int(arenaDimensions().height))
        }
            
        }
        print("Second hit")
        turnRobotLeft(Int(abs(170)))
        moveAhead(450)
    }
    func goHere(here: Int)
    {
     //Trying random moves first
        randRun()
        currentRobotState = .RunAway
        
    }
    func randRun()
    {
     let randSide = arc4random_uniform(2) + 1
      var randTurns = arc4random_uniform(5) + 1
        randTurns *= 10
        let turn = CGFloat(randTurns)
        if randSide > 1
        {
            turnRobotRight(Int(abs(turn)))
            moveAhead(700)
        }else{
            turnRobotLeft(Int(abs(turn)))
            moveAhead(700)
        }
    
    }
    override func hitWall(hitDirection: RobotWallHitDirection, hitAngle angle: CGFloat) {
        cancelActiveAction()
        
        // save old state
//        let previousState = currentRobotState
//        currentRobotState = .Turnaround
        
        // always turn directly away from wall
        if angle >= 0 {
            turnRobotLeft(Int(abs(angle)))
        } else {
            turnRobotRight(Int(abs(angle)))
        }
        
        // leave wall
        moveAhead(20)
        
        // reset to old state
        currentRobotState = .KillMode
    }
    
    override func bulletHitEnemy(bullet: Bullet!) {
        let pos = bullet.position
     turnToEnemyPosition(pos)
        // unimplemented but could be powerful to use this...
    }
    func turnToEnemyPosition(position: CGPoint) {
        cancelActiveAction()
        
        // calculate angle between turret and enemey
        let angleBetweenTurretAndEnemy = angleBetweenGunHeadingDirectionAndWorldPosition(position)
        
        // turn if necessary
        if angleBetweenTurretAndEnemy > gunToleranceAngle {
            turnGunRight(Int(abs(angleBetweenTurretAndEnemy)))
        } else if angleBetweenTurretAndEnemy < -gunToleranceAngle {
            turnGunLeft(Int(abs(angleBetweenTurretAndEnemy)))
        }
        
        shoot()
        shoot()
    }
    
    
}