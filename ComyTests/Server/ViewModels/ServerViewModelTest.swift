//
//  ServerViewModelTest.swift
//  ComyTests
//
//  Created by Quentin on 24/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import XCTest
import Starscream
import RxSwift
@testable import Comy

class ServerViewModelTest: XCTestCase {

     private let testStateResponseJSON = "{\"commands\" : [{\"imageURL\" : \"https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/6sided_dice.jpg/800px-6sided_dice.jpg\", \"mainParameter\" : {\"defaultValue\" : \"1\", \"name\" : \"Number of dices\", \"typeCode\" : 1}, \"name\" : \"Fake dice\"}, {\"name\" : \"Test1\"}, {\"name\" : \"Test2\"}], \"name\" : \"Test server\", \"type\" : \"ServerStateResponse\"}"
       private let testCommandResponseJSON = "{\"commandName\" : \"Test1\", \"result\" : {\"message\" : \"\", \"status\" : {\"message\" : \"OK\", \"success\" : true}}, \"type\" : \"CommandResponse\"}"
       
       private let disposeBag = DisposeBag()

       override func setUpWithError() throws {
           // Put setup code here. This method is called before the invocation of each test method in the class.
       }

       override func tearDownWithError() throws {
           // Put teardown code here. This method is called after the invocation of each test method in the class.
       }

       func testDidReceiveStateResponse() throws {
           //Arrange
           let absolutelyUselessRequest = URLRequest(url: URL(string: "https://absolutelynotawebsite.com")!)
           let services = ServerServices(request: absolutelyUselessRequest)
           services.connect()
           let serverViewModel = ServerViewModel(services: services)
           services.delegate = serverViewModel
           let stateResponse = try! JSONDecoder().decode(ServerStateResponse.self, from: testStateResponseJSON.data(using: .utf8)!)
           
           //Act
           serverViewModel.services.didReceive(event: .text(testStateResponseJSON), client: WebSocket(request: absolutelyUselessRequest))
           
           //Assert
           XCTAssert((try! serverViewModel.commands.value()).map(\.name).sorted() == stateResponse.commands.map(\.name).sorted())
       }
       
       func testDidReceiveCommandResponse() throws {
           
           let expectation = XCTestExpectation(description: "Waiting for command response")
           
           //Arrange
           let absolutelyUselessRequest = URLRequest(url: URL(string: "https://absolutelynotawebsite.com")!)
           let services = ServerServices(request: absolutelyUselessRequest)
           services.connect()
           let serverViewModel = ServerViewModel(services: services)
           services.delegate = serverViewModel
           let commandResponseFromJSON = try! JSONDecoder().decode(CommandResponse.self, from: testCommandResponseJSON.data(using: .utf8)!)
           
           //Act & Assert
           serverViewModel.commandResponse
               .subscribe(onNext: { (commandResponse) in
                   XCTAssert(commandResponse.commandName == commandResponseFromJSON.commandName && commandResponse.result.message == commandResponseFromJSON.result.message)
                   expectation.fulfill()
                   return
               })
               .disposed(by: disposeBag)
           serverViewModel.services.didReceive(event: .text(testCommandResponseJSON), client: WebSocket(request: absolutelyUselessRequest))
           
           wait(for: [expectation], timeout: 5)
       }

}
