//
//  APIManager.swift
//  Bazaar-iOS
//
//  Created by Muhsin Etki on 23.11.2020.
//

import UIKit
import Alamofire

struct APIManager {
    let dateFormatter = DateFormatter()
    
    enum MyError: Error {
        case runtimeError(String)
    }
    
    func authenticate(username:String,password:String,completionHandler: @escaping (Result<String ,Error>) -> Void) {
        do {
            let request = try ApiRouter.authenticate(username: username, password: password).asURLRequest()
            AF.request(request).responseJSON { (response) in
                if (response.response?.statusCode != nil){
                    guard let safeData = response.data else  {
                        completionHandler(.failure(response.error!))
                        return
                    }
                    if let decodedData:AuthData = APIParse().parseJSON(safeData: safeData){
                        completionHandler(.success(decodedData.token))
                        UserDefaults.standard.setValue(String(decodedData.user_id), forKey: K.user_id)
                        UserDefaults.standard.setValue(String(decodedData.token), forKey: K.token)
                    }else {
                        completionHandler(.failure(MyError.runtimeError("Error")))
                    }
                }
            }
        }catch let err {
            completionHandler(.failure(err))
        }
    }
    
    
    func getAllProducts(completionHandler: @escaping ([ProductData]?) -> Void) {
        let callURL = "http://13.59.236.175:8000/api/product/"
        if let url = URL(string: callURL){
            AF.request(url).responseJSON(completionHandler: {
                response in
                if response.data != nil {
                    do {
                        let allProducts = try JSONDecoder().decode([ProductData].self, from: response.data!)
                        AllProducts.shared.jsonParseError = false
                        AllProducts.shared.apiFetchError = false
                        AllProducts.shared.dataFetched = true
                        completionHandler(allProducts)
                    } catch {
                        print("error while decoding JSON for all products")
                        AllProducts.shared.jsonParseError = true
                        AllProducts.shared.dataFetched = false
                        completionHandler(nil)
                    }
                } else {
                    print("error while decoding JSON for all products")
                    AllProducts.shared.apiFetchError = true
                    AllProducts.shared.dataFetched = false
                    completionHandler(nil)
                }
                
            })
        } else {
            print("invalid url for getting all products")
            AllProducts.shared.apiFetchError = true
            AllProducts.shared.dataFetched = false
            completionHandler(nil)
        }
            
    }
    
    
    func getCustomerLists(customer:String, isCustomerLoggedIn:Bool, completionHandler: @escaping (Result<[CustomerListData] , Error>) -> Void) {
        do {
            let request = try ApiRouter.getCustomerLists(customer: customer, isCustomerLoggedIn: isCustomerLoggedIn).asURLRequest()
            AF.request(request).responseJSON { (response) in
                if (response.response?.statusCode != nil){
                    guard let safeData = response.data else  {
                        completionHandler(.failure(response.error!))
                        return
                    }
                    if let decodedData:[CustomerListData] = APIParse().parseJSON(safeData: safeData){
                        completionHandler(.success(decodedData))
                    }else {
                        completionHandler(.failure(MyError.runtimeError("Error")))
                    }
                }
            }
        }catch let err {
            completionHandler(.failure(err))
        }
    }
    
    func addList(name:String, customer:String, isPrivate:Bool, completionHandler: @escaping (Result<Int ,Error>) -> Void) {
        do {
            let request = try ApiRouter.addList(name: name, customer: customer, isPrivate: isPrivate).asURLRequest()
            AF.request(request).responseJSON { (response) in
                if (response.response?.statusCode != nil){
                    guard let safeData = response.data else  {
                        completionHandler(.failure(response.error!))
                        return
                    }
                    if let decodedData:CustomerListData = APIParse().parseJSON(safeData: safeData) {
                        completionHandler(.success(decodedData.id))
                    }else {
                        completionHandler(.failure(MyError.runtimeError("Error")))
                    }
                }
            }
        }catch let err {
            completionHandler(.failure(err))
        }
    }
    
    func deleteList(customer:String, id:String , completionHandler: @escaping (Result<String ,Error>) -> Void) {
        do {
            let request = try ApiRouter.deleteList(customer: customer, id: id).asURLRequest()
            AF.request(request).responseJSON { (response) in
                if (response.response?.statusCode != nil){
                    guard let safeData = response.data else  {
                        completionHandler(.failure(response.error!))
                        return
                    }
                    if let decodedData:[String:String] = APIParse().parseJSON(safeData: safeData), decodedData.values.first != "not allowed to access"{
                        completionHandler(.success("success"))
                        print("hey")
                    }else {
                        completionHandler(.failure(MyError.runtimeError("Error")))
                    }
                }
            }
        }catch let err {
            completionHandler(.failure(err))
        }
    }
    
    
}
