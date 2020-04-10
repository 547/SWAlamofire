//
//  SWNetwork.swift
//  SWAlamofire
//
//  Created by Supernova SanDick SSD on 2019/6/18.
//  Copyright © 2019 Seven. All rights reserved.
//

import Foundation
import Alamofire

open class SWNetwork {
    public static let `default` = SWNetwork()
    public let networkReachabilityChangedNotificationName = Notification.Name.init("NETWORK_REACHABILITY_CHANGED")

    private lazy var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 30
        let result = SessionManager.init(configuration: configuration)
        return result
    }()
    private let reachabilityManager: NetworkReachabilityManager? = NetworkReachabilityManager.init(host: "www.baidu.com")
    
    private(set) var currentReachability: SWNetwork.Reachability = .unknown {
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
extension SWNetwork {
    private func notifyNetworkReachabilityStatusChanged() {
        NotificationCenter.default.post(name: networkReachabilityChangedNotificationName, object: nil)
    }
}
extension SWNetwork {
    open func api(_ api: SWNetworkApi) -> SWNetworkRequest {
        return SWNetworkRequest(api: api)
    }
    @discardableResult
    open func request(_ request: SWNetworkRequest) -> SWNetwork {
        
        
        let urlString = request.api.url
        var method:HTTPMethod{
            var result = HTTPMethod.get
            switch request.api.method {
            case .options:
                result = .options
            case .get:
                result = .get
            case .head:
                result = .head
            case .post:
                result = .post
            case .put:
                result = .put
            case .patch:
                result = .patch
            case .delete:
                result = .delete
            case .trace:
                result = .trace
            case .connect:
                result = .connect
            }
            return result
        }
        let parameters = request.api.parameters
        let headers = request.headers
        
        willRequest(request)
        if let files = request.api.files, files.count > 0 {
            sessionManager.upload(multipartFormData: { (multipartFormData) in
                if let pars = parameters {
                    pars.forEach { (item) in
                        if let value = item.value as? String, let data = value.data(using: .utf8) {
                            multipartFormData.append(data, withName: item.key)
                        }
                        if let value = item.value as? Int, let data = "\(value)".data(using: .utf8) {
                            multipartFormData.append(data, withName: item.key)
                        }
                        if let value = item.value as? [String] {
                            value.forEach { (string) in
                                let key = item.key + "[]"
                                if let data = string.data(using: .utf8) {
                                    multipartFormData.append(data, withName: key)
                                }
                            }
                        }
                        if let value = item.value as? [Int] {
                            value.forEach { (num) in
                                let key = item.key + "[]"
                                if let data = "\(num)".data(using: .utf8) {
                                    multipartFormData.append(data, withName: key)
                                }
                            }
                        }
                    }
                }
                files.forEach({ (file) in
                    multipartFormData.append(file.fileData, withName: file.parameterName, fileName: file.fileName, mimeType: file.mimeType.rawValue)
                })
            }, to: urlString, method: method, headers: headers) {[weak self] (multipartFormDataEncodingResult) in
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
        }else {
            /**
             * get、delete 两种方法的参数 parameters 会被自动拼接到url 后面
             * post、patch、put的参数 parameters 则是在请求体body里面
             */
            let dataRequest = sessionManager.request(urlString, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            if let url = dataRequest.request?.url?.absoluteString {
                request.api.url = url
            }
            dataRequest.responseJSON(options: jsonSerializationReadingOption) {[weak self] (dataResponse) in
                if let error = dataResponse.error {
                    self?.onFailure(request, error)
                }else{
                    self?.onSuccess(request, dataResponse.result.value)
                }
            }
        }
        return self
    }
}

extension SWNetwork {
    private func willRequest(_ request: SWNetworkRequest) {
        guard request.debugRequest else { return }
        print("\(request)")
    }
    private func didResponse(_ response: SWNetworkResponse) {
        guard response.request.debugResponse else { return }
        print("\(response)")
    }
}

extension SWNetwork {
    open func onSuccess(_ request: SWNetworkRequest, _ object: Any?) {
        var response = SWNetworkResponse(request: request)
        
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
    
    open func onFailure(_ request: SWNetworkRequest, _ error: Error?) {
        let code = (error as NSError?)?.code ?? -1
        let response = SWNetworkResponse.failure(with: request, code: code, message: error?.localizedDescription ?? "No Error Message")
        
        didResponse(response)
        onFinished(response)
    }
    
    private func onFinished(_ response: SWNetworkResponse) {
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
