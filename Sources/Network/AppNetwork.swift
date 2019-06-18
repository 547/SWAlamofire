//
//  AppNetwork.swift
//  iFoodMacau
//
//  Created by Jason Lee on 2018/7/12.
//  Copyright © 2018 CYCON.com. All rights reserved.
//

import Foundation
import Alamofire

public class AppNetwork {
    public static let `default` = AppNetwork()
    public let networkReachabilityChangedNotificationName = Notification.Name.init("NETWORK_REACHABILITY_CHANGED")

    private lazy var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 5
        let result = SessionManager.init(configuration: configuration)
        return result
    }()
    private let reachabilityManager: NetworkReachabilityManager? = NetworkReachabilityManager.init(host: "www.baidu.com")
    
    private(set) var currentReachability: AppNetwork.Reachability = .unknown {
        didSet {
            if oldValue != currentReachability {
                notifyNetworkReachabilityStatusChanged()
            }
        }
    }
    
    private let jsonSerializationReadingOption = JSONSerialization.ReadingOptions.allowFragments
    
    init() {
        reachabilityManager?.listener = { [weak self] status in
            guard let weakSelf = self else { return }
            switch status {
            case .unknown:
                weakSelf.currentReachability = .unknown
            case .notReachable:
                weakSelf.currentReachability = .unreachable
            case .reachable(let type):
                if type == .wwan{
                    weakSelf.currentReachability = .viaWWAN
                }else{
                    weakSelf.currentReachability = .viaWiFi
                }
            }
        }
        reachabilityManager?.startListening()
    }
}
extension AppNetwork {
    private func notifyNetworkReachabilityStatusChanged() {
        NotificationCenter.default.post(name: networkReachabilityChangedNotificationName, object: nil)
    }
}
extension AppNetwork {
    public func api(_ api: AppNetworkApi) -> AppNetworkRequest {
        return AppNetworkRequest(api: api)
    }
    @discardableResult
    public func request(_ request: AppNetworkRequest) -> AppNetwork {
        
        
        let url = request.api.url
        var method:HTTPMethod{
            var result = HTTPMethod.get
            switch request.api.method {
            case .post:
                result = .post
            case .get:
                result = .get
            case .upload:
                result = .post
            case .patch:
                result = .patch
            case .put:
                result = .put
            case .delete:
                result = .delete
            case .putUpload:
                result = .put
            }
            return result
        }
        let parameters = request.api.parameters
        let headers = request.headers
        /**
         * get、delete 两种方法的参数 parameters 会被自动拼接到url 后面
         * post、patch、put的参数 parameters 则是在请求体body里面
         */
        let dataRequest = sessionManager.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers)
        if let url = dataRequest.request?.url?.absoluteString {
            request.api.url = url
        }
        
        willRequest(request)
        if request.api.method != .upload {
            dataRequest.responseJSON(options: jsonSerializationReadingOption) {[weak self] (dataResponse) in
                if let error = dataResponse.error {
                    self?.onFailure(request, error)
                }else{
                    self?.onSuccess(request, dataResponse.result.value)
                }
            }
        }else if let files = request.api.files, request.api.method == .upload {
            sessionManager.upload(multipartFormData: { (multipartFormData) in
                files.forEach({ (file) in
                    multipartFormData.append(file.fileData, withName: file.parameterName, fileName: file.fileName, mimeType: file.mimeType.rawValue)
                })
            }, to: url) {[weak self] (multipartFormDataEncodingResult) in
                switch multipartFormDataEncodingResult {
                case .success( let uploadRequest, _, _):
                    uploadRequest.responseJSON(completionHandler: { (dataResponse) in
                        if let error = dataResponse.error {
                            self?.onFailure(request, error)
                        }else{
                            self?.onSuccess(request, dataResponse.result.value)
                        }
                    })
                    uploadRequest.uploadProgress(closure: { (progress) in
                        request.progressing?(progress)
                    })
                case .failure(let error):
                    self?.onFailure(request, error)
                }
            }
        }
        return self
    }
}

extension AppNetwork {
    private func willRequest(_ request: AppNetworkRequest) {
        guard request.debugRequest else { return }
        print("\(request)")
    }
    private func didResponse(_ response: AppNetworkResponse) {
        guard response.request.debugResponse else { return }
        print("\(response)")
    }
}

extension AppNetwork {
    public func onSuccess(_ request: AppNetworkRequest, _ object: Any?) {
        var response = AppNetworkResponse(request: request)
        
        if let result = request.api.responseSuccess?(object, response) {
            response = result
        } else if let result = request.responseSuccess?(object, response) {
            response = result
        } else {
            if let dictObject = object as? [String : Any] {
                response.data = dictObject
            }else if let arrayObject = object as? [Any] {
                response.data = ["list" : arrayObject]
            }else if let data = object as? Data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: jsonSerializationReadingOption){
                    if let dic = json as? [String: Any] {
                        response.data = dic
                    }else{
                        response.data = ["data" : json]
                    }
                }
            }else if let anyObject = object {
                response.data = ["data" : anyObject]
            }
        }
        
        didResponse(response)
        onFinished(response)
    }
    
    public func onFailure(_ request: AppNetworkRequest, _ error: Error?) {
        let code = (error as NSError?)?.code ?? -1
        let response = AppNetworkResponse.failure(with: request, code: code, message: error?.localizedDescription ?? "No Error Message")
        
        didResponse(response)
        onFinished(response)
    }
    
    private func onFinished(_ response: AppNetworkResponse) {
        guard !response.request.isCancel else {
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let currentDate = dateFormatter.string(from: Date())
            print("[REQUEST CANCELED] ********** \(currentDate)\n" + "[API]\n\(response.request.api.apiName)\n")
            return
        }
        response.request.finished?(response)
    }
}
