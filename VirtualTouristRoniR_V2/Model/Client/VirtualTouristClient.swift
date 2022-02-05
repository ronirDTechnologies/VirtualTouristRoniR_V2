//
//  VirtualTouristClient.swift
//  VIrtualTourist_RoniR
//
//  Created by Roni Rozenblat on 1/24/20.
//  Copyright © 2020 dinatech. All rights reserved.
//
import Foundation

class VirtualTouristClient
{
    
    
    enum Endpoints
    {
        static let apiKey = "9c9b65a976aaedfa68740bb7830d9464"
        static let base = "https://www.flickr.com/services/rest/"
        
        case getPhotosForLocation(String,String,String,String,String)
        
        
        var stringValue: String
        {
            switch self
            {
            case .getPhotosForLocation(let method, let lon, let lat,let extras, let formatFlag):     return Endpoints.base + "?method=" + method + "&api_key=" + Endpoints.apiKey + "&lat=" +   lat+"&lon="+lon + "&extras=" + extras + "&format="+formatFlag + "&nojsoncallback=1&per_page=50"
            }
        }
        
        var url: URL
        {
            return URL(string: stringValue)!
        }
    }
    
    // TODO: LOOK INTO Camel Case of Class Names 02-05-2020
    class func GetPhotosForLatLon(latVal: String, lonVal: String, completion:@escaping (Photos?, Error?) -> Void)
    {
        
        //let method, let apiKeyVal, let lon, let lat,let extras, let formatFlag
        taskForGETRequest(url: Endpoints.getPhotosForLocation( "flickr.photos.search", lonVal,latVal,"url_t","json").url, responseType: PhotoResponse.self){
            (response,error) in
            if let response = response
            {
                DispatchQueue.main.async
                {
                    completion(response.photos, nil)
                }
            }
            else
            {
                DispatchQueue.main.async
                {
                    completion(response?.photos, error)
                }
            }
            
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url:URL, responseType: ResponseType.Type,completion: @escaping(ResponseType?,Error?)->Void) -> URLSessionTask
    {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
                return
            }
        
        let decoder = JSONDecoder()
            do
            {
                
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async
                {
                    completion(responseObject, nil)
                }
                
            }
            catch
            {
                do{
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async
                    {
                        completion(nil,errorResponse)
                        print("ERROR RESPONSE \(errorResponse)")
                    }
                }
                catch
                {
                    DispatchQueue.main.async
                    {
                        completion(nil, error)
                    }
                }
                
                
            }
        }
        task.resume()
        return task
        
    }
    
}
