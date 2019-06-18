//
//  AppNetworkConfig.swift
//  iFoodMacau
//
//  Created by Jason Lee on 2018/7/12.
//  Copyright © 2018 CYCON.com. All rights reserved.
//

import Foundation

// Enumeration
extension AppNetwork {
    /// 请求方法
    public enum HttpMethod { case post, get, upload, putUpload, patch, put, delete }
    
    /// 媒体类型
    public enum MimeType: String {
        case jpeg   = "image/jpeg"
        case png    = "image/png"
        case bmp    = "image/bmp"
        case mp4    = "mp4"
        
        /// 文件名后缀
        public var suffix: String {
            switch self {
            case .jpeg: return ".jpg"
            case .png:  return ".png"
            case .bmp:  return ".bmp"
                
            case .mp4:  return ".mp4"
            }
        }
    }
    
    /// 网络状态
    public enum Reachability {
        case unknown, unreachable, viaWWAN, viaWiFi
    }
}

// Protocol
/// 网络组件API格式协议
public class AppNetworkApi {
    public typealias ResponseSuccess = (Any?, AppNetworkResponse) -> AppNetworkResponse
    /// 请求方法
    public var method: AppNetwork.HttpMethod = .get
    /// 目标url
    public var url: String = ""
    /// 参数与数据
    public var parameters: [String: Any]?
    /// 文件
    public var files: [AppNetwork.UploadingFile]?
    /// 回调成功操作
    public var responseSuccess: ResponseSuccess?
    /// 调用方法名
    public var functionName: String = ""
    /// 初始化方法
}
extension AppNetworkApi {
    /// 接口名
    public static var apiName: String { return String(describing: self.self) }
    public var apiName: String { return String(describing: self) }
}

// Structure
extension AppNetwork {
    // 上传文件结构体
    public struct UploadingFile {
        public var fileData: Data
        public var parameterName: String
        public var fileName: String
        public var mimeType: MimeType
        public init(fileData: Data, parameterName: String, fileName: String, mimeType: MimeType) {
            self.fileData = fileData
            self.parameterName = parameterName
            self.fileName = fileName + mimeType.suffix
            self.mimeType = mimeType
        }
    }
}

public class NetworkConfig {
    public var `protocol`:String{
        return ""
    }
    public var host:String{
        return ""
    }
    public var port:Int?{
        return nil
    }
    public var path:String{
        return ""
    }
}
extension AppNetworkApi {
    public func get(app: String = "") -> AppNetworkRequest {
        let newUrl = ""
        
        return AppNetworkRequest.init(api: self)
    }
    
}

