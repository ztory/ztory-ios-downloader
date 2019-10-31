//
//  DownloaderQueueManager.swift
//  
//
//  Created by Christian Rönningen on 2019-10-31.
//

import Foundation

public class DownloaderQueueManager {
    static let shared: DownloaderQueueManager = DownloaderQueueManager()
    
    private var downloadQueue = [Downloader]()
    private var runningDownloader: Downloader? = nil
    
    func add(downloader: Downloader, first: Bool) {
        if downloadQueue.contains(downloader) == false {
            registerNotifications(on: downloader)
        }
        
        if first {
            runningDownloader?.pause()
            downloadQueue.insert(downloader, at: 0)
        } else {
            downloadQueue.append(downloader)
        }
        
        runningDownloader = downloadQueue.first
        runningDownloader?.start()
    }
    
    func remove(downloader: Downloader) -> Bool {
        unregisterNotifications(on: downloader)
        
        downloader.stop()
        downloadQueue.removeAll { (dl) -> Bool in
            return dl == downloader
        }
        
        runningDownloader = downloadQueue.first
        runningDownloader?.start()
        
        return true
    }
    
    func registerNotifications(on downloader: Downloader) {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(downloaderDidStartDownloading(notification:)),
                                       name: .DownloaderDidStart,
                                       object: downloader)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(downloaderDidCompleteDownloading(notification:)),
                                       name: .DownloaderDidComplete,
                                       object: downloader)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(downloaderDidStopDownloading(notification:)),
                                       name: .DownloaderDidStop,
                                       object: downloader)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(downloaderDidFailDownloading(notification:)),
                                       name: .DownloaderDidFail,
                                       object: downloader)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(downloaderDidPauseDownloading(notification:)),
                                       name: .DownloaderDidPause,
                                       object: downloader)
    }
    
    func unregisterNotifications(on downloader: Downloader) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: .DownloaderDidStart, object: downloader)
        notificationCenter.removeObserver(self, name: .DownloaderDidComplete, object: downloader)
        notificationCenter.removeObserver(self, name: .DownloaderDidStop, object: downloader)
        notificationCenter.removeObserver(self, name: .DownloaderDidFail, object: downloader)
        notificationCenter.removeObserver(self, name: .DownloaderDidPause, object: downloader)
    }
    
    // MARK: Notification handling
    @objc
    func downloaderDidStartDownloading(notification: Notification) {
        if let downloader = notification.object as? Downloader {
            downloaderDidStartDownloading(downloader: downloader)
        }
    }
    
    @objc
    func downloaderDidCompleteDownloading(notification: Notification) {
        if let downloader = notification.object as? Downloader {
            downloaderDidCompleteDownloading(downloader: downloader)
        }
    }
    
    @objc
    func downloaderDidStopDownloading(notification: Notification) {
        if let downloader = notification.object as? Downloader {
            downloaderDidStopDownloading(downloader: downloader)
        }
    }
    
    @objc
    func downloaderDidFailDownloading(notification: Notification) {
        if let downloader = notification.object as? Downloader {
            downloaderDidFailDownloading(downloader: downloader)
        }
    }
    
    @objc
    func downloaderDidPauseDownloading(notification: Notification) {
        if let downloader = notification.object as? Downloader {
            downloaderDidPauseDownloading(downloader: downloader)
        }
    }
}

extension DownloaderQueueManager: DownloaderDelegate {
    public func downloaderDidCompleteDownloading(downloader: Downloader) {
        remove(downloader: downloader)
    }
    
    public func downloaderDidFailDownloading(downloader: Downloader) {
        remove(downloader: downloader)
    }
    
    public func downloaderDidStopDownloading(downloader: Downloader) {
        remove(downloader: downloader)
    }
    
    public func downloaderDidPauseDownloading(downloader: Downloader) {
        //
    }
    
    public func downloaderDidStartDownloading(downloader: Downloader) {
        //
    }
}
