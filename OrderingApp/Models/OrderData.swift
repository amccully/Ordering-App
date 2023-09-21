//
//  OrderData.swift
//  OrderingApp
//
//  Created by Aaron McCully
//

import Foundation

class OrderData: ObservableObject {
    
    // the orderData variable will be used to access the user's order information in other parts of the app
    public static var orderData = OrderData()
    
    @Published var hasOrder = false
    @Published var currentOrder = ""
    @Published var estimatedFinishTime = ""
    @Published var orderId = ""
    
    // currently commented out, as there is no RestAPI being used in this prototype version
    // @Published var restID = ""
    
    // coordinates of the order's location will be needed if
    // the users chooses to "get directions" to their order
    // note: restaurant has coordinate info, is there a reason we have order store these coords too?
    @Published var long = 0.0
    @Published var lat = 0.0
}
