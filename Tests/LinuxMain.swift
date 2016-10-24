//
//  LinuxMain.swift
//  Epoch
//
//  Created by Kevin Hury on 20/10/2016.
//
//

import XCTest
@testable import EpochAuthTests
@testable import MeetappTests

XCTMain([  
    testCase(RequestAuthTests.allTests),
    testCase(EventsControllerTests.allTests),
    testCase(EventTests.allTests),
])
