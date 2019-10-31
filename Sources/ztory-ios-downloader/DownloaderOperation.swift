//
//  DownloaderOperation.swift
//  
//
//  Created by Christian Rönningen on 2019-10-31.
//

import Foundation

public typealias DownloaderOperationCompletion = (Result<DownloaderOperation, NSError>) -> Void

open class DownloaderOperation: Operation {
    private let remote: URL
    private let destination: URL
    private let session: URLSession
    private var completion: DownloaderOperationCompletion?
    
    private var downloadTask: URLSessionDownloadTask?
    
    private var error: NSError?
    
    private var _executing: Bool = false
    private var _finished: Bool = false
    
    public init(remote: URL, destination: URL, session: URLSession, completion: DownloaderOperationCompletion?) {
        self.remote = remote
        self.destination = destination
        self.session = session
        
        super.init()
        
        if completion != nil {
            self.completionBlock = { [weak self] in
                guard let self = self else { return }
                if let error = self.error {
                    completion?(.failure(error))
                } else {
                    completion?(.success(self))
                }
            }
        }
    }
    
    public override func cancel() {
        super.cancel()
        
        downloadTask?.cancel()
    }
    
    public override func start() {
        if isCancelled {
            willChangeValue(forKey: "isFinished")
            _finished = true
            didChangeValue(forKey: "isFinished")
        }
        
        downloadTask = session.downloadTask(with: URLRequest(url: remote), completionHandler: { (url, response, error) in
            
        })
        
        willChangeValue(forKey: "isExecuting")
        downloadTask?.resume()
        _executing = true
        didChangeValue(forKey: "isExecuting")
    }
    
    static func validateResponse(response: HTTPURLResponse) -> Bool {
        return validateStatusCode(code: response.statusCode)
    }
    
    static func validateStatusCode(code: Int) -> Bool {
        return Array(200..<300).contains(code)
    }
    
    public override var isFinished: Bool {
        return _finished
    }
    
    public override var isExecuting: Bool {
        return _executing
    }
    
    public override var isAsynchronous: Bool {
        return true
    }
    
    public override var isConcurrent: Bool {
        return true
    }
    
    private func completeOperation() {
        willChangeValue(forKey: "isFinished")
        willChangeValue(forKey: "isExecuting")
        
        _executing = false
        _finished = true
        
        didChangeValue(forKey: "isFinished")
        didChangeValue(forKey: "isExecuting")
    }
}
