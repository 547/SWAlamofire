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
    public enum HttpMethod { case options, get, head, post, put, patch, delete, trace, connect }
    
    /// 媒体类型
    public enum MimeType: String {
        ///.*（ 二进制流，不知道下载文件类型）
        case any    = "application/octet-stream"
        ///.001
        case x001   = "application/x-001"
        ///.323
        case h323   = "text/h323"
        case jpeg   = "image/jpeg"
        case png    = "image/png"
        case bmp    = "image/bmp"
        case mp4    = "video/mpeg4"
        
        /// 文件名后缀
        public var suffix: String {
            switch self {
            case .any:  return ".*"
            case .x001: return ".001"
            case .h323: return ".323"
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
open class SWNetworkApi {
    public typealias ResponseSuccess = (Any?, SWNetworkResponse) -> SWNetworkResponse
    /// 请求方法
    open var method: SWNetwork.HttpMethod = .get
    /// 目标url
    open var url: String = ""
    /// 参数与数据
    open var parameters: [String: Any]?
    /// 文件
    open var files: [SWNetwork.UploadingFile]?
    /// 回调成功操作
    open var responseSuccess: ResponseSuccess?
    /// 调用方法名
    open var functionName: String = ""
    /// 初始化方法
    public init() {}
}
extension SWNetworkApi {
    /// 接口名
    public static var apiName: String { return String(describing: self.self) }
    open var apiName: String { return String(describing: self) }
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

open class SWNetworkConfig {
    open var `protocol`:String{
        return ""
    }
    open var host:String{
        return ""
    }
    open var port:Int?{
        return nil
    }
    open var path:String{
        return ""
    }
}
extension SWNetworkApi {
    open func get(app: String = "") -> SWNetworkRequest {
        let _ = ""
        
        return SWNetworkRequest.init(api: self)
    }
    
}

