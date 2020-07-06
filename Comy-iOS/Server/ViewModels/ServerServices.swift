//
//  ServerServices.swift
//  Comy-iOS
//
//  Created by Quentin on 12/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import Starscream

class ServerServices {
    
    private var socket: WebSocket
    var token: String?
    var refreshToken: String?
    private var currentExecutionCommands: [Command:[String:String]] = [:]
    private var waitingRefreshTokenCommands: [Command:[String:String]] = [:]
    private var isWaitingRefreshTokenToGetState = false
    weak var delegate: ServerServicesDelegate?
    
    var url: String? {
        return socket.request.url?.absoluteString
    }
    
    init(request: URLRequest){
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func connect() {
        socket.connect()
    }
    
    func authentificate(id: String, password: String) {
        socket.write(string: String(data: try! JSONEncoder().encode(AuthenticationUserMessage(username: id, password: password)), encoding: .utf8)!)
    }
    
    private func handleAuthResponse(response: AuthenticationResponse) {
        if let token = response.token {
            self.token = token
            if let refreshToken = response.refreshToken { //auth came from username and password
                self.refreshToken = refreshToken
                ServerCredentials.saveCredentials(url: socket.request.url!.absoluteString, accessToken: token, refreshToken: refreshToken)
                delegate?.onAuthentification(success: true)
            } else if response.message == "refreshed token" { //we need to reexecute commands and get state if needed
                print("Token successfully refreshed, executing commands : \(waitingRefreshTokenCommands)")
                for command in waitingRefreshTokenCommands {
                    executeCommand(command: command.key, params: command.value)
                }
                if isWaitingRefreshTokenToGetState {
                    refreshState()
                }
            }
        } else if response.message == "error with refresh token" { //auth tokens are not valid
            waitingRefreshTokenCommands = [:]
            ServerCredentials.deleteCredentials(url: socket.request.url!.absoluteString)
            self.disconnect()
        } else {
            ServerCredentials.deleteCredentials(url: socket.request.url!.absoluteString)
            delegate?.onAuthentification(success: false)
        }
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func refreshState() {
        socket.write(string: String(data: try! JSONEncoder().encode(NeedStateMessage(token: token)), encoding: .utf8)!)
    }
    
    func refreshAuthToken() {
        guard let refreshToken = refreshToken else { return }
        socket.write(string: String(data: try! JSONEncoder().encode(RefreshTokenMessage(refreshToken: refreshToken)), encoding: .utf8)!)
    }
    
    func executeCommand(command: Command, params: [String:String]) {
        currentExecutionCommands[command] = params
        socket.write(string: String(data: try! JSONEncoder().encode(ExecuteCommandMessage(commandName: command.name, params: params, token: token)), encoding: .utf8)!)
    }
    
    deinit {
        socket.disconnect()
    }
    
}

extension ServerServices: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        print(event)
        switch event {
        case .text(let stringEvent):
            if let dataEvent = stringEvent.data(using: .utf8){
                if let serverInfoResponse = try? JSONDecoder().decode(ServerInfoResponse.self, from: dataEvent) {
                    delegate?.didReceiveServerInfo(infos: serverInfoResponse)
                } else if let authResponse = try? JSONDecoder().decode(AuthenticationResponse.self, from: dataEvent) {
                    handleAuthResponse(response: authResponse)
                }
                else if let serverStateResponse = try? JSONDecoder().decode(ServerStateResponse.self, from: dataEvent){
                    if let authError = serverStateResponse.authError, authError.tokenExpiredError, !isWaitingRefreshTokenToGetState { //need to refresh token and get state
                        isWaitingRefreshTokenToGetState = true
                        self.refreshAuthToken()
                    } else {
                        isWaitingRefreshTokenToGetState = false
                        delegate?.didReceiveNewState(state: serverStateResponse)
                    }
                } else if let commandResponse = try? JSONDecoder().decode(CommandResponse.self, from: dataEvent){
                    if let authError = commandResponse.authError, authError.tokenExpiredError, !waitingRefreshTokenCommands.map(\.key.name).contains(commandResponse.commandName) { //need to refresh token and restart command
                        guard let commandToReexecuteAfterRefresh = currentExecutionCommands.first(where: {$0.key.name == commandResponse.commandName}) else { return }
                        print("ERROR: TOKEN EXPIRED ! refreshing token...")
                        waitingRefreshTokenCommands[commandToReexecuteAfterRefresh.key] = commandToReexecuteAfterRefresh.value
                        self.refreshAuthToken()
                    } else { //Command execution completed (successfully or not)
                        if let currentExecutionCommand = currentExecutionCommands.keys.first(where: {$0.name == commandResponse.commandName}) {
                            currentExecutionCommands.removeValue(forKey: currentExecutionCommand)
                        }
                        if let currentWaitingCommand = waitingRefreshTokenCommands.keys.first(where: {$0.name == commandResponse.commandName}) {
                            waitingRefreshTokenCommands.removeValue(forKey: currentWaitingCommand)
                        }
                        print("waitingRefreshTokenCommands: \(waitingRefreshTokenCommands)")
                        print("currentExecutionCommands: \(currentExecutionCommands)")
                        delegate?.didReceiveCommandResult(response: commandResponse)
                    }
                }
            }
        case .connected(_):
            delegate?.onConnected()
        case .disconnected(let reason, let code):
            delegate?.onDisconnected(reason: reason, code: code)
        case .cancelled:
            delegate?.onDisconnected(reason: "Cancelled", code: 200)
        default:
            return
        }
    }
    
}

protocol ServerServicesDelegate: class {
    func onConnected()
    func onAuthentification(success: Bool)
    func onDisconnected(reason: String, code: UInt16)
    func didReceiveServerInfo(infos: ServerInfoResponse)
    func didReceiveNewState(state: ServerStateResponse)
    func didReceiveCommandResult(response: CommandResponse)
}
