//
//  SWNetworkConfig.swift
//  SWAlamofire
//
//  Created by Supernova SanDick SSD on 2019/6/18.
//  Copyright © 2019 Seven. All rights reserved.
//

import Foundation

// Enumeration
extension SWNetwork {
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
public class SWNetworkApi {
    public typealias ResponseSuccess = (Any?, SWNetworkResponse) -> SWNetworkResponse
    /// 请求方法
    public var method: SWNetwork.HttpMethod = .get
    /// 目标url
    public var url: String = ""
    /// 参数与数据
    public var parameters: [String: Any]?
    /// 文件
    public var files: [SWNetwork.UploadingFile]?
    /// 回调成功操作
    public var responseSuccess: ResponseSuccess?
    /// 调用方法名
    public var functionName: String = ""
    /// 初始化方法
    public init() {}
}
extension SWNetworkApi {
    /// 接口名
    public static var apiName: String { return String(describing: self.self) }
    public var apiName: String { return String(describing: self) }
}

// Structure
extension SWNetwork {
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

public class SWNetworkConfig {
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
extension SWNetworkApi {
    public func get(app: String = "") -> SWNetworkRequest {
        let _ = ""
        
        return SWNetworkRequest.init(api: self)
    }
    
}

