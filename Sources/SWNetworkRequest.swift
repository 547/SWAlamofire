//
//  SWNetworkRequest.swift
//  SWAlamofire
//
//  Created by Supernova SanDick SSD on 2019/6/18.
//  Copyright © 2019 Seven. All rights reserved.
//

import Foundation

/**
 *  网络组件
 *  自定义Request
 */

public class SWNetworkRequest {
    public typealias NetworkProgressing = (Progress) -> Void
    public typealias NetworkRequestFinished = (SWNetworkResponse) -> Void
    public typealias NetworkResponseSuccess = (Any?, SWNetworkResponse) -> SWNetworkResponse
    
    public var api: SWNetworkApi
    
    private(set) var progressing:     NetworkProgressing? = nil
    private(set) var finished:        NetworkRequestFinished? = nil
    private(set) var responseSuccess: NetworkResponseSuccess? = nil
    
    public var isCancel:           Bool = false
    public var debugRequest:       Bool = true
    public var debugResponse:      Bool = true
    public var debugResponseData:  Bool = true
    
    public var headers: [String : String]? = nil
    
    public init(api: SWNetworkApi) {
        self.api = api
    }
}

extension SWNetworkRequest {
    @discardableResult
    public func onProgressing(_ closure: NetworkProgressing?) -> Self {
        progressing = closure
        return self
    }
    @discardableResult
    public func onFinished(_ closure: NetworkRequestFinished?) -> Self {
        finished = closure
        SWNetwork.default.request(self)
        return self
    } 
    @discardableResult
    public func onResponseSuccess(_ closure: NetworkResponseSuccess?) -> Self {
        responseSuccess = closure
        return self
    }
}

extension SWNetworkRequest: CustomStringConvertible {
    public var description: String {
        let parametersString = "\(api.parameters != nil ? "\(api.parameters!)" : "No parameters")\n"
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = dateFormatter.string(from: Date())
        var returningString = "[NETWORK REQUEST] \n********** \(currentDate) **********\n" +
            "[API]\n\(api.functionName)\n" + 
            "[URL]\n\(api.url)\n" +
            "[METHOD]\n\(api.method)\n" +
        "[PARAMETERS]\n\(parametersString)\n"
        
        if let files = self.api.files {
            returningString.append("[FILES]\n\(files.count > 0 ? "" : "No Files")")
            for file in files {
                returningString.append("<File name=\"\(file.parameterName)\" length=\"\(file.fileData.count)\">\(file.fileName)</File>")
                returningString.append("\n")
            }
        }
        return returningString
    }
}



