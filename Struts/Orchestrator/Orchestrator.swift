//
//  Orchestrator.swift
//  Struts
//
//  Created by Yunarta on 17/9/18.
//  Copyright © 2018 mobilesolution works. All rights reserved.
//

import Foundation

/**
  Orchestrator orchestrate flow of UI to fullfil a WorkProcess.
 
  The class orchestrate by using the WorkProcess instance and setting up the screens that are needed to finish
  the process.
 */
public class Orchestrator<WP>: NSObject where WP: WorkProcess {

    let workProcess: WP

    public init(process: WP) {
        self.workProcess = process
    }

    public func start() {

    }
}
