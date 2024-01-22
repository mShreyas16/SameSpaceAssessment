//
//  SongListViewModel.swift
//  SamespaceAssignment
//
//  Created by Shreyas Mandhare on 17/01/24.
//

import Foundation

class SongListViewModel {
    
    //MARK: Properties
    var songListData: SongListModel?
    var bindData: ((Serviceresponse) -> Void) = {_ in }
    
    
    func getData() {
        
        SongListService().serviceCall { SongListModel, Serviceresponse in
            
            if Serviceresponse == .success {
                self.songListData = SongListModel
                self.bindData(.success)
                
            }
            
            if Serviceresponse == .failed {
                self.bindData(.failed)
            }
        }
        
        
    }
    
}
