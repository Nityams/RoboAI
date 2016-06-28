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
    
    
    var robostate: SState = .Default
    
    
    override func run()
    {
        switch robostate {
        case .Default:
            doDefaultStuffs();
            break
        default:
            doRunAwayStuffs();
        }
    }
    
    func doDefaultStufs(){
        
        
    }
    func doRunAwayStuffs(){
        
    }
    
    override func bulletHitEnemy(bullet: Bullet!) {
        var thisway:bullet.position
    }
    
}