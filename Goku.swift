//
//  Goku.swift
//  RobotWarsOSX
//
//  Created by Nityam Shrestha on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation

class Goku: Robot{
    enum SState{
        case Default, Runaway
        
    }
    let arenaSize = self.arenaDimensions()
    
    
    var robostate: SState = .Default
    
    
    override func run()
    {
        switch robostate {
        case .Default:
            doDefaultStuffs()
            break
        default:
            doRunAwayStuffs()
        }
    }
    
    func doDefaultStuffs(){
      //var mypos = position()
        
        moveAhead(950)
        
        
    }
    func doRunAwayStuffs(){
        
    }
    override func hitWall(hitDirection: RobotWallHitDirection, hitAngle: CGFloat) {
        // always turn directly away from wall
       
        
        if(position() == CGPoint(x: 0, y: 0) || position() == CGPoint(x: 0, y: arenaSize) || position() == CGPoint(x: arenaSize, y: 0)  || position() == CGPoint(x: arenaSize, y: arenaSize))
        {
            return
        }
        
        turnRobotLeft(Int(abs(180)))
        turnRobotLeft(Int(abs(90)))
        moveAhead(900)
        
    }
    override func bulletHitEnemy(bullet: Bullet!) {
        //var thisway:bullet.position
    }
    
}