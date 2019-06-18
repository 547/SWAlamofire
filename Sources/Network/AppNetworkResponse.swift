//
//  AppNetworkResponse.swift
//  iFoodMacau
//
//  Created by Jason Lee on 2018/7/12.
//  Copyright © 2018 CYCON.com. All rights reserved.
//

import Foundation

public class AppNetworkResponse {
    private(set) var request: AppNetworkRequest
    public var code:       Int = -1
    public var message:    String? = nil
    public var data:       [String: Any]? = nil
    
    public init(request: AppNetworkRequest) { self.request = request }
}

extension AppNetworkResponse {
    public static func success(with request: AppNetworkRequest, code: Int) -> AppNetworkResponse {
        let response = AppNetworkResponse(request: request)
        response.code = code
        return response
    }
    public static func failure(with request: AppNetworkRequest, code: Int, message: String? = nil) -> AppNetworkResponse {
        let response = AppNetworkResponse(request: request)
        response.code = code
        response.message = message
        return response
    }
}

extension AppNetworkResponse: CustomStringConvertible {
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
