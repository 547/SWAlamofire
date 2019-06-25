//
//  SWNetworkResponse.swift
//  SWAlamofire
//
//  Created by Supernova SanDick SSD on 2019/6/18.
//  Copyright © 2019 Seven. All rights reserved.
//

import Foundation

public class SWNetworkResponse {
    private(set) var request: SWNetworkRequest
    public var code:       Int = -1
    public var message:    String? = nil
    public var data:       [String: Any]? = nil
    
    public init(request: SWNetworkRequest) { self.request = request }
}

extension SWNetworkResponse {
    public static func success(with request: SWNetworkRequest, code: Int) -> SWNetworkResponse {
        let response = SWNetworkResponse(request: request)
        response.code = code
        return response
    }
    public static func failure(with request: SWNetworkRequest, code: Int, message: String? = nil) -> SWNetworkResponse {
        let response = SWNetworkResponse(request: request)
        response.code = code
        response.message = message
        return response
    }
}

extension SWNetworkResponse: CustomStringConvertible {
    public var description: String {
        let parametersString = "\(request.api.parameters != nil ? "\(request.api.parameters!)" : "No parameters")\n"
        let dataString = request.debugResponseData ? "\(data != nil ? "\(data!)" : "No data")\n" : "Hidden data"
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = dateFormatter.string(from: Date())
        var returningString = "[NETWORK RESPONSE] \n********** \(currentDate) **********\n" +
            "[API]\n\(request.api.functionName)\n" +
            "[URL]\n\(request.api.url)\n" +
            "[METHOD]\n\(request.api.method)\n" +
        "[PARAMETERS]\n\(parametersString)"
        
        if let files = request.api.files {
            returningString.append("[FILES]\n\(files.count > 0 ? "" : "No Files")")
            for file in files {
                returningString.append("<File name=\"\(file.parameterName)\" length=\"\(file.fileData.count)\">\(file.fileName)</File>")
                returningString.append("\n")
            }
            
        }
        
        returningString += "[CODE]\n\(code)\n" +
            "[MESSAGE]\n\(message ?? "No message")\n" +
        "[DATA]\n\(dataString)\n"
        return returningString
    }
}
