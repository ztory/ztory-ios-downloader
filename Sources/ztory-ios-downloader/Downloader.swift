//
//  Downloader.swift
//  
//
//  Created by Christian Rönningen on 2019-10-31.
//

import Foundation

public protocol DownloaderDelegate: class {
    func downloaderDidStartDownloading(downloader: Downloader)
    func downloaderDidStopDownloading(downloader: Downloader)
    func downloaderDidFailDownloading(downloader: Downloader)
    func downloaderDidPauseDownloading(downloader: Downloader)
    func downloaderDidCompleteDownloading(downloader: Downloader)
}

public enum DownloaderSpeed: Int {
    case max = 8
    case min = 4
}

public extension Notification.Name {
    static let DownloaderDidComplete = Notification.Name("com.zmdownloader.ZMDownloaderDidCompleteNotification")
    static let DownloaderDidStart = Notification.Name("com.zmdownloader.ZMDownloaderDidStartNotification")
    static let DownloaderDidStop = Notification.Name("com.zmdownloader.ZMDownloaderDidStopNotification")
    static let DownloaderDidFail = Notification.Name("com.zmdownloader.ZMDownloaderDidFailNotification")
    static let DownloaderDidPause = Notification.Name("com.zmdownloader.ZMDownloaderDidPauseNotification")
}

open class Downloader: NSObject {
    private let operationQueueContext = UnsafeMutableRawPointer(bitPattern: 0)
    
    var isRunning: Bool = false
    
    private var delegate: DownloaderDelegate?
    private let session: URLSession
    public let operationQueue: OperationQueue = OperationQueue()
    
    public init(delegate: DownloaderDelegate?, operations: [Operation], session: URLSession, defaultDownloadSpeed: DownloaderSpeed = .min) {
        self.delegate = delegate
        self.session = session
        
        super.init()
        
        operationQueue.isSuspended = true
        operationQueue.maxConcurrentOperationCount = defaultDownloadSpeed.rawValue
        operationQueue.addOperations(operations, waitUntilFinished: false)
        
        operationQueue.addObserver(self, forKeyPath: #keyPath(OperationQueue.operationCount), options: .new, context: operationQueueContext)
    }
    
    deinit {
        operationQueue.removeObserver(self, forKeyPath: #keyPath(OperationQueue.operationCount), context: operationQueueContext)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == operationQueueContext {
            if operationQueue.operationCount == 0 {
                DispatchQueue.main.async {
                    self.delegate?.downloaderDidCompleteDownloading(downloader: self)
                    NotificationCenter.default.post(name: .DownloaderDidComplete, object: self)
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func start() {
        if isRunning == false {
            isRunning = true
            operationQueue.isSuspended = false
            delegate?.downloaderDidStartDownloading(downloader: self)
            NotificationCenter.default.post(name: .DownloaderDidStart, object: self)
        }
    }
    
    func stop() {
        if isRunning {
            isRunning = false
            operationQueue.isSuspended = true
            delegate?.downloaderDidStopDownloading(downloader: self)
            NotificationCenter.default.post(name: .DownloaderDidStop, object: self)
        }
    }
    
    func pause() {
        if isRunning {
            isRunning = false
            operationQueue.isSuspended = true
            delegate?.downloaderDidPauseDownloading(downloader: self)
            NotificationCenter.default.post(name: .DownloaderDidPause, object: self)
        }
    }
    
    func throttleDownloadSpeed() {
        operationQueue.maxConcurrentOperationCount = DownloaderSpeed.min.rawValue
    }
    
    func increaseDownloadSpeed() {
        operationQueue.maxConcurrentOperationCount = DownloaderSpeed.max.rawValue
    }
}
