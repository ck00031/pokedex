//
//  NetworkManager.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/22.
//

import Alamofire

enum FBEAPIStatus :Error{
    case Success
    case Failure
}

class NetworkManager:NSObject{
    fileprivate var afManager: SessionManager!
    typealias NetworkFinishedCadable = (_ status:FBEAPIStatus, _ result:Data?, _ tipString: String?) -> ()
    
    public class var sharedInstance : NetworkManager {
        struct Static {
            static let instance : NetworkManager = NetworkManager()
        }
        
        return Static.instance
    }

    override init() {
        super.init()
        
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            configuration.urlCache = nil
            configuration.timeoutIntervalForRequest = 10
            configuration.httpCookieAcceptPolicy = .never
            configuration.httpShouldSetCookies = false
            
            return configuration
        }()
        
        afManager = SessionManager(
            configuration: configuration
        )
        
    }
}

extension NetworkManager {
        func getWithRouterDecodable(Router:URLRequestConvertible, finished: @escaping NetworkFinishedCadable){
            if let url = Router.urlRequest?.url?.absoluteString {
                if let localData = APICacheManager.sharedInstance.loadCache(key: url) {
                    finished(.Success, localData, nil)
                    return
                }
            }
            
            afManager.request(Router).validate().responseJSON {
                response in
                self.handleWithCodable(response: response, finished: finished)
            }
        }
    
        fileprivate func handleWithCodable(response: DataResponse<Any>, finished: @escaping NetworkFinishedCadable) {
            if response.result.isSuccess {
                if let data = response.data, let url = response.request?.url?.absoluteString {
                    APICacheManager.sharedInstance.saveCache(key: url, data: data)
                }
                
                finished(.Success,response.data,nil)
                return
            }
            
            finished(.Failure,response.data,nil)
        }
}
