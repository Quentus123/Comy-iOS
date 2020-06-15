//
//  ServerCommandsController.swift
//  Comy-iOS
//
//  Created by Quentin on 11/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ServerCommandsController: UIViewController{
    
    @IBOutlet weak var commandsTableView: UITableView!
    @IBOutlet weak var shutdownButton: UIButton!
    @IBOutlet weak var nameServerLabel: UILabel!
    @IBOutlet weak var notConnectedLabel: UILabel!
    
    private var serverViewModel: ServerViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var request = URLRequest(url: URL(string: "ws://localhost:12478")!)
        request.timeoutInterval = 5
        serverViewModel = ServerViewModel(request: request)
        commandsTableView.register(CommandCell.self, forCellReuseIdentifier: "CommandCell")
        commandsTableView.rx.setDelegate(self)
        
        serverViewModel.serverName.bind(to: nameServerLabel.rx.text).disposed(by: disposeBag)
        
        //temporary
        serverViewModel.isConnected.bind(to: shutdownButton.rx.isHidden.mapObserver({!$0})).disposed(by: disposeBag)
        serverViewModel.isConnected.bind(to: notConnectedLabel.rx.isHidden).disposed(by: disposeBag)
        
        serverViewModel.commandResult
            .subscribe(onNext: { [weak self] (result) in
                guard let self = self else { return }
                if result.status.success {
                    let message = result.result.count > 0 ? result.result : nil
                    let successAlert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(successAlert, animated: true)
                } else {
                    let errorAlert = UIAlertController(title: "Error", message: result.status.message, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        serverViewModel.commands.bind(to: commandsTableView.rx.items(cellIdentifier: "CommandCell", cellType: CommandCell.self)) { [weak self] row, item, cell in
            
            guard let self = self else { return }
            cell.nameLabel.text = item.name
            self.serverViewModel.imagesData
                .filter { (dict) -> Bool in
                    dict.keys.contains(item.name)
                }
                .map({$0[item.name]})
                .subscribe(onNext: { (data) in
                    guard let data = data else { return }
                    cell.backgroundImageView.image = UIImage(data: data)
                })
                .disposed(by: self.disposeBag)
            cell
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { _ in
                    self.serverViewModel.services.executeCommand(command: item)
                })
                .disposed(by: self.disposeBag)
            cell
                .rx
                .longPressGesture(configuration: { (gestureReco, _) in
                    gestureReco.minimumPressDuration = 0.01
                    gestureReco.numberOfTouchesRequired = 1
                    gestureReco.numberOfTapsRequired = 0
                    gestureReco.allowableMovement = 1.0
                })
                .when(.began, .ended)
                .subscribe(onNext: { pan in
                    UIView.animate(withDuration: 0.3) {
                        switch pan.state {
                        case .began:
                            cell.mainContainer.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                        case .ended:
                            cell.mainContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
                        default:
                            break
                        }
                    }
                })
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
}

extension ServerCommandsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
}
