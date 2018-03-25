//
//  StatusView.swift
//  Wallet
//
//  Created by Cake Technologies 12/8/17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

protocol StatusView {
    func initProgress(description: String, initialProgress: Float, icon: UIImage?)
    func initProgress(description: String, initialProgress: Float)
    func updateProgress(_ updatingProgress: NewBlockUpdate)
    func finishProgress(withText text: String)
    func finishProgress(withText text: String, icon: UIImage?)
    func finishProgress()
    func update(status: NetworkStatus)
}

final class StatusViewImpl: BaseView {
    let descriptionLabel: UILabel
    let iconView: UIImageView
    let progressView: UIProgressView
    private var timer: Timer?
    
    required init() {
        descriptionLabel = UILabel(font: .avenirNextMedium(size: 14))
        iconView = UIImageView()
        progressView = UIProgressView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = .clear
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 0
        progressView.progressTintColor = .lightGreen
        progressView.trackTintColor = UIColor(hex: 0xd4d3da) // FIX-ME: Unnamed constant
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 1
        addSubview(iconView)
        addSubview(descriptionLabel)
        addSubview(progressView)
    }
    
    override func configureConstraints() {
        if let titleView = titleView {
            titleView.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(15)
            }
        
            descriptionLabel.snp.makeConstraints { make in
                make.top.equalTo(titleView.snp.bottom)
                make.leading.equalToSuperview().offset(15)
                if !iconView.isHidden {
                    make.trailing.equalTo(iconView.snp.leading)
                } else {
                    make.trailing.equalToSuperview().offset(-15)
                }
                
                 make.trailing.lessThanOrEqualToSuperview().offset(-15)
            }
        } else {
            descriptionLabel.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.width.equalTo(descriptionLabel.snp.width)
            }
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
        
        iconView.snp.makeConstraints { make in
            make.leading.equalTo(descriptionLabel.snp.trailing).offset(5)
            make.height.equalTo(15)
            make.width.equalTo(15)
            make.centerY.equalTo(descriptionLabel.snp.centerY)
        }
    }
}

extension StatusViewImpl: StatusView {
    func initProgress(description: String, initialProgress: Float) {
        initProgress(description: description, initialProgress: initialProgress, icon: nil)
    }
    
    func finishProgress(withText text: String) {
        finishProgress(withText: text, icon: nil)
    }
    
    func initProgress(description: String, initialProgress: Float, icon: UIImage? = nil) {
        descriptionLabel.text = description
        progressView.progress = initialProgress
        
        if let icon = icon {
            iconView.image = icon
        } else {
            iconView.image = nil
        }
    }
    
    func updateProgress(_ progress: Float, text: String) {
        progressView.progress = progress
        descriptionLabel.text = text
    }
    
    func updateProgress(_ updatingProgress: NewBlockUpdate) {
        let progress = updatingProgress.calculateProgress()
        let percents = progress * 100
        progressView.progress = progress
        descriptionLabel.text = "Blocks remaining: \(updatingProgress.blocksRemaining) (\(String(format: "%.2f", percents))%)"
        
        if progressView.isHidden {
            progressView.isHidden = false
        }
    }
    
    func finishProgress(withText text: String, icon: UIImage? = nil) {
        progressView.progress = 0
        descriptionLabel.text = text
        
        if let icon = icon {
            iconView.image = icon
        } else {
            iconView.image = nil
        }
    }
    
    func finishProgress() {
        progressView.progress = 0
        descriptionLabel.text = "Done"
    }
    
    func update(status: NetworkStatus) {
        switch status {
        case .failedConnection(_):
            break
        default:
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
        }
        
        switch status {
        case let .failedConnection(date):
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .short
            
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                    let time = Date().timeIntervalSince(date)
                    
                    if let formattedDate = formatter.string(from: time) {
                        self?.setDescription("Trying to connect to remote node (\(formattedDate)).", hideProgressBar: true)
                    } else {
                        self?.setDescription("Trying to connect to remote node.", hideProgressBar: true)
                    }
                })
            }
            // Failed connection to daemon.
            setDescription("Trying to connect to remote node.", hideProgressBar: true)
            self.timer?.fire()
        case .notConnected:
            setDescription("Not connected", hideProgressBar: true)
        case .connecting:
            setDescription("Connecting", hideProgressBar: true)
        case .connected:
            setDescription("Connected")
        case .startUpdating:
            initProgress(description: "Start syncing", initialProgress: 0)
        case .updated:
            finishProgress(
                withText: "Synchronized",
                icon: UIImage.fontAwesomeIcon(
                    name: .check,
                    textColor: .lightGray,
                    size: CGSize(width: 15, height: 15)))
            
        case let .updating(status):
            updateProgress(status)
        }
    }
    
    private func setDescription(_ text: String, hideProgressBar: Bool = true) {
        descriptionLabel.text = text
        iconView.image = nil
        
        if progressView.isHidden != hideProgressBar {
            progressView.isHidden = hideProgressBar
        }
    }
}
