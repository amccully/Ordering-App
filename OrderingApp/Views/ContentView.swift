//
//  ContentView.swift
//  OrderingApp
//
//  Created by Aaron McCully
//
import SwiftUI
import CoreLocationUI
import CoreLocation

enum HTTPErrors: Error {
    case HTTPRequestError
}

struct ContentView: View {
    
    @StateObject var model: ModelData = ModelData()
    
    //@State private var showingSheet = false
    //@State var selectedDetent: PresentationDetent = .fraction(0.25)
    @State private var showingOptions = false
    @State var byFoot = true
    @State var search: String = ""
    
    //@State private var transportMode = "byFoot"
    //var transportTypes = ["byFoot", "byBike"]
    //@State public var searchType = "Convenience"
    //var searchTypes = ["Convenience", "Wait Time", "Distance Away"]
    
    //!!!!!
    // @State var displayed: [Restaurant] = []
    
    var body: some View {
        TabView {
            NavigationView {
                List {
                    Section {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            // change to allow user to choose what they search by (name, wait time, finish by, etc)
                            TextField("Search...", text: $search)
                            
                            Button(action: {
                                //showingSheet.toggle()
                                showingOptions.toggle()
                            }, label: {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.gray)
                                    .font(.title)
                            })
                            .confirmationDialog("Sort by...", isPresented: $showingOptions, titleVisibility: .visible) {
                                ForEach(UserInfo.searchTypes, id: \.self) { type in
                                    Button(type) {
                                        UserInfo.searchType = type
                                    }
                                }
                            }
                        }
                    }
                    Section {
                        let filtered = search != "" ? model.restaurants.values.sorted().filter { restaurant in restaurant.name.lowercased().contains(search.lowercased())} : model.restaurants.values.sorted()
                        let filteredSpecial = UserInfo.searchType == UserInfo.searchTypes[1] ? filtered.sorted(by: { $0.waitTime < $1.waitTime }) : filtered.sorted(by: { $0.distanceAway < $1.distanceAway })
                        ForEach(UserInfo.searchType == UserInfo.searchTypes[0] ? filtered : filteredSpecial) { restaurant in
                            NavigationLink(destination: RestaurantDetailView(id: restaurant.id).environmentObject(model)) {
                                
                                HStack {
                                    // option 1
//                                    Text(restaurant.name)
//                                    Spacer()
//                                    Image(systemName: "timer")
//                                    Text("\(restaurant.waitTime)")
//                                    //Spacer()
//                                    HStack {
//                                        Spacer()
//                                        Text("\(restaurant.distanceAsString()) mi")
//                                    }
//                                    .frame(width: 70)
                                    // option 2
//                                    HStack {
//                                        Text(restaurant.name)
//                                        Spacer()
//                                    }
//                                    .frame(width: 150)
//                                    Image(systemName: "timer")
//                                    Text("\(restaurant.waitTime)")
//                                    Spacer()
//                                    Text("\(restaurant.distanceAsString()) mi")
                                    // option 3
                                    Text(restaurant.name)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        HStack {
                                            if restaurant.isOpen {
                                                Text("\(restaurant.waitTime)")
                                                Image(systemName: "timer")
                                            }
                                            else {
                                                Text("Closed")
                                            }
                                        }
                                        .foregroundColor((restaurant.waitTime <= 10 && restaurant.isOpen) ? .green : (restaurant.waitTime <= 30 && restaurant.isOpen) ? .orange : .red)
                                        //.padding(.bottom, 1)
                                        // change for testing
                                        Text("\(restaurant.distanceAsString()) mi")
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("OrderingApp")
                // ADIN'S ADDED ANIMATION, BUT DIDN'T WORK WHEN NOT USING RESTAPI (RESTAURANTS WEREN'T LOADING UNLESS SORT TYPE WAS CHANGED)
                
//                .animation(.default, value: search)
//                .animation(.default, value: displayed)
//                .onChange(of: search) { newValue in
//                    let filtered = search != "" ? model.restaurants.values.sorted().filter { restaurant in restaurant.name.lowercased().contains(search.lowercased())} : model.restaurants.values.sorted()
//                    let filteredSpecial = UserInfo.searchType == UserInfo.searchTypes[1] ? filtered.sorted(by: { $0.waitTime < $1.waitTime }) : filtered.sorted(by: { $0.distanceAway < $1.distanceAway })
//                    displayed = UserInfo.searchType == UserInfo.searchTypes[0] ? filtered : filteredSpecial
//                }
                .task {
                    model.locationManager.checkIfLocationServicesIsEnabled()
                    await loadData()
                }
                .refreshable {
                    Task {
                        model.locationManager.checkIfLocationServicesIsEnabled()
                        await loadData()
                    }
                }
            }.tabItem {
                Label("List", systemImage: "list.bullet")
            }
            
            MapView()
                .environmentObject(model)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            OrderInfoView()
                .environmentObject(model)
                .tabItem {
                    Label("Order", systemImage: "doc.text")
                }
        }
    }
    
    func loadData() async {

        model.restaurants = [
            "001": Restaurant(id: "001", name: "Subway", description: "This is a test for the view. *Insert Name* makes garbage food that tastes absolutely amazing. Hands-down the best fastfood joint you can go to!", openHour: 6, openMinute: 0, closeHour: 2, closeMinute: 00, latitude: 32.881398208652115, longitude: -117.23520934672317, waitTime: 28, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 8, money: 1),
            "002": Restaurant(id: "002", name: "Panda Express", description: "This is a test for the view. *Insert Name* makes garbage food that tastes absolutely amazing. Hands-down the best fastfood joint you can go to!", openHour: 9, openMinute: 50, closeHour: 22, closeMinute: 30, latitude: 32.884638, longitude: -117.239104, waitTime: 5, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 8, money: 1),
            "003": Restaurant(id: "003", name: "Burger King", description: "This is a test for the view. *Insert name* makes garbage food that tastes absolutely amazing. Hands-down the best fastfood joint you can go to!", openHour: 6, openMinute: 30, closeHour: 1, closeMinute: 0, latitude: 32.8809679784332, longitude: -117.23547474701675, waitTime: 8, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 3, money: 1),
            "004": Restaurant(id: "004", name: "Triton Grill", description: "Located in Muir College on campus. We feature made-to-order sushi, an expansive salad and deli bar, grill and cantina specials, as well as, a decadent dessert station.", openHour: 7, openMinute: 0, closeHour: 1, closeMinute: 0, latitude: 32.88076184401626, longitude: -117.2430254489795, waitTime: 8, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 12, money: 2),
            "005": Restaurant(id: "005", name: "Lemongrass", description: "Located in Muir College on campus. We feature made-to-order sushi, an expansive salad and deli bar, grill and cantina specials, as well as, a decadent dessert station.", openHour: 7, openMinute: 0, closeHour: 1, closeMinute: 0, latitude: 32.8819619, longitude: -117.24311, waitTime: 5, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 12, money: 2)
        ]

        // start point of possibly fucked code
//        let url: URL = URL(string: "http://127.0.0.1:5000/IDs")!
//        var list_ids: [String] = []
//        do {
//            let (data, response) = try await URLSession.shared.data(from: url)
//
//            guard let httpResponse = response as? HTTPURLResponse,
//                  httpResponse.statusCode == 200 else {
//                throw RestaurantError.HTTPRequestError
//
//            }
//            guard let httpResponse = response as? HTTPURLResponse,
//                  httpResponse.statusCode == 200 else {
//                throw RestaurantError.HTTPRequestError
//
//            }
//
//            let dic_ids = try JSONDecoder().decode([String:[String]].self, from: data)
//            list_ids = dic_ids["ids"]!
//            for id in list_ids {
//                model.restaurants[id] = try await Restaurant(id: id, model: model)
//            }
//
//            displayed = model.restaurants.values.sorted()
//
//        }
//        catch {
//            print("WHOOOPS")
//            print("Error is \(error)")
//            model.restaurants = [:]
//        }
        // end point
        
        // getting user coordinates as a CLLocation
        if let unwrappedLocation = model.locationManager.location {
            let userCoords = CLLocation(latitude: unwrappedLocation.latitude,
                                        longitude: unwrappedLocation.longitude)
            // settings restaurant distances
            model.restaurants.values.sorted().forEach { restaurant in
                let distance = (userCoords.distance(from: CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude)) / 1000) * 0.621371
                restaurant.setDistanceAway(_distanceAway: distance)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
