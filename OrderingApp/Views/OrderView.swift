//
//  OrderView.swift
//  OrderingApp
//
//  Created by Aaron McCully
//

import SwiftUI

struct OrderView : View {
    
    @EnvironmentObject var model: ModelData
    @ObservedObject var orderData = OrderData.orderData
    
    @State var userOrderStr = ""
    @State var userOrderList = [String]()
    @State var showAlert = false
    let id: String
    var restaurant: Restaurant {
        model.restaurants[id]!
    }
    
    // Temporary:
    // @State var qty = 0
    // Change to determine how much of a given item a person can order. As of now, this is a single value that is the same across all menu items and restaurants
    // let maxQty = 5
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Menu item:")
                        Spacer()
                        Text("Add to order:")
                    }
                    ForEach(restaurant.menuItems, id: \.self) { item in
                        HStack {
                            Text(item)
                            Spacer()
                            Button {
                                addToOrder(item: item)
                            } label: {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.green)
                                    .font(.title)
                                    .frame(width: 95)
                            }
                        }
                    }
                }
                Section {
                    Text("Your order: \(userOrderStr)")
                    Button {
                       clearOrder()
                    } label: {
                        Text("Clear Order")
                            .foregroundColor(.red)
                    }
                    Button {
                        showAlert.toggle()
                    } label: {
                        Text("Place Order")
                            .foregroundColor(Color.blue)
                    }
                    .alert(isPresented: $showAlert) {
                        if !restaurant.isOpen {
                            return Alert(
                                title: Text("\(restaurant.name) is closed")
                            )
                        }
                        else if userOrderStr.isEmpty {
                            return Alert(
                                title: Text("Please add items to your order")
                            )
                        }
                        else if orderData.hasOrder {
                            return Alert(
                                title: Text("You already have an active order!")
                            )
                        }
                        else {
                            return Alert(
                                title: Text("Confirm order?"),
                                primaryButton: .default(
                                    Text("Yes"),
                                    action: sendOrder
                                ),
                                secondaryButton: .destructive(
                                    Text("Cancel")
                                )
                            )
                        }
                    }
                }
            }
            .navigationTitle(restaurant.name)
        }
    }
    
    func clearOrder() {
        userOrderList.removeAll()
        userOrderStr = ""
    }

    func addToOrder(item: String) {
        userOrderList.append(item)
        userOrderStr = orderListToString()
    }
    
    // probably not a great approach but works
    func orderListToString() -> String {
        var userStr = ""
        userOrderList.forEach { obj in
            userStr += "\(obj), "
        }
        userStr.removeLast(2)
        return userStr
    }
    
    func sendOrder() {
        // this will be a list containing all items of the order, use this in with api request
        // userOrderList
        
        // Add your code here:
        // was previously commented out, do not uncomment as of now
        // restName: str, orderTime: int, items: list, numInLine: int, orderId: str
        
        let date = Date()
        var hours = Calendar.current.component(.hour, from: date)
        let mins = Calendar.current.component(.minute, from: date)
        let orderId = UUID().uuidString
//        orderData.orderId = orderId
//        orderData.restID = restaurant.id
//        orderData.long = restaurant.longitude
//        orderData.lat = restaurant.latitude
        let order = ["restName" : restaurant.name, "currTime":hours*60 + mins, "items":userOrderList, "orderID": orderId, "numInLine": restaurant.numInLine!] as [String : Any]

        let fullURL = URL(string: "http://127.0.0.1:5000/restaurant/" + restaurant.id + "/orders")!

        var request = URLRequest(url: fullURL)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        let data = try! JSONSerialization.data(withJSONObject: order, options: .prettyPrinted)

        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making PUT request: \(error.localizedDescription)")
                return
            }

            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    print("Invalid response code: \(responseCode)")
                    return
                }

                if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                    print("Response JSON data = \(responseJSONData)")
                }
            }
        }.resume()
        
        orderData.hasOrder = true
        orderData.currentOrder = "\(restaurant.name): " + userOrderStr
        var calc = mins + restaurant.waitTime
        while calc >= 60 {
            hours+=1
            calc-=60
        }
        // might need proofing? check cases
        orderData.estimatedFinishTime = "\(hours % 12 == 0 ? 12 : hours % 12):\(String(format: "%02d", calc)) \(hours > 11 ? "PM" : "AM")"
        
        clearOrder()
    }
}

//struct OrderView_Previews : PreviewProvider {
//    static var previews: some View {
//        OrderView(id: "001")
//    }
//}
