//
//  SongListService.swift
//  SamespaceAssignment
//
//  Created by Shreyas Mandhare on 17/01/24.
//

import Foundation

enum Serviceresponse {
    case inProgress
    case success
    case failed
}



class SongListService {
    
    typealias completionHandler = ((SongListModel?,Serviceresponse) -> ())
    
    func serviceCall(completion: @escaping completionHandler) {
        
        var request = URLRequest(url: URL(string: "https://cms.samespace.com/items/songs")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                completion(nil, Serviceresponse.failed)
                return
            }
            
            let songListModelObject = try? JSONDecoder().decode(SongListModel.self, from: data)
            completion(songListModelObject, Serviceresponse.success)
            
        }
        
        task.resume()
        
    }
    
    
}
