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
    @IBOutlet weak var notificationView: NotificationView!
    
    private var baseNotificationViewBottomConstraintConstant: CGFloat!
    private var timerHideNotification: Timer?
    
    var serverViewModel: ServerViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseNotificationViewBottomConstraintConstant = view.constraints.filter({$0.firstAnchor == notificationView.bottomAnchor}).first!.constant
        hideNotificationView()
        notificationView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.hideNotificationView()
            })
            .disposed(by: disposeBag)
        
        commandsTableView.register(CommandCell.self, forCellReuseIdentifier: "CommandCell")
        commandsTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        serverViewModel.serverName.bind(to: nameServerLabel.rx.text).disposed(by: disposeBag)
        
        serverViewModel.commandsLoading
            .subscribe(onNext: { [weak self] commands in
                guard let self = self else { return }
                for cell in self.commandsTableView.visibleCells {
                    guard let cell = cell as? CommandCell else { return }
                    UIView.animate(withDuration: 0.1) {
                        cell.mainContainer.alpha = commands.contains(cell.nameLabel.text!) ? 0.5 : 1
                    }
                }
            })
            .disposed(by: disposeBag)
        
        self.shutdownButton
            .rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.serverViewModel.disconnect()
            })
            .disposed(by: disposeBag)
        
        serverViewModel.isConnected
            .filter({!$0})
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        serverViewModel.commandResponse
            .subscribe(onNext: { [weak self] (response) in
                guard let self = self else { return }
                if response.result.status.success && response.result.message.count > 0 {
                    let successAlert = UIAlertController(title: "Success", message: response.result.message, preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(successAlert, animated: true)
                } else if response.result.status.success && response.result.message.count == 0{
                    self.showNotificationView()
                } else {
                    let errorAlert = UIAlertController(title: "Error", message: response.result.status.message, preferredStyle: .alert)
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
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.hideNotificationView()
                    self.serverViewModel.executeCommand(command: item)
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
    
    private func hideNotificationView() {
        let oldBottomConstraint = self.view.constraints.filter({$0.firstAnchor == notificationView.bottomAnchor}).first!
        guard oldBottomConstraint.constant < 0 else { return }
        let newBottomConstraint = NSLayoutConstraint(item: notificationView as Any,
                                                     attribute: .bottom,
                                                     relatedBy: .equal,
                                                     toItem: view,
                                                     attribute: .bottom,
                                                     multiplier: 1,
                                                     constant: -oldBottomConstraint.constant + 70)
        UIView.animate(withDuration: 0.5) {
            self.view.removeConstraint(oldBottomConstraint)
            self.view.addConstraint(newBottomConstraint)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    private func showNotificationView() {
        timerHideNotification?.invalidate()
        
        let oldBottomConstraint = self.view.constraints.filter({$0.firstAnchor == notificationView.bottomAnchor}).first!
        guard oldBottomConstraint.constant > 0 else { return }
        let newBottomConstraint = NSLayoutConstraint(item: notificationView as Any,
                                                     attribute: .bottom,
                                                     relatedBy: .equal,
                                                     toItem: view,
                                                     attribute: .bottom,
                                                     multiplier: 1,
                                                     constant: baseNotificationViewBottomConstraintConstant)
        UIView.animate(withDuration: 0.5) {
            self.view.removeConstraint(oldBottomConstraint)
            self.view.addConstraint(newBottomConstraint)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        
        timerHideNotification = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.hideNotificationView()
        }
    }
    
}

extension ServerCommandsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
}
