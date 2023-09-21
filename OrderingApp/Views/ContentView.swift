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
    
    // this bool will tell us whether the options pop-up (which shows the possible ways to sort the restaurants) is currently active or not
    @State private var showingOptions = false
    // string will be used to filter the restaurants shown by name
    @State var search: String = ""
    
    var body: some View {
        TabView {
            NavigationView {
                List {
                    searchSection
                    restaurantSection
                }
                .navigationTitle("OrderingApp")
                .task {
                    model.locationManager.checkIfLocationServicesIsEnabled()
                    await loadData()
                }
                .refreshable {
                    model.locationManager.checkIfLocationServicesIsEnabled()
                    await loadData()
                }
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }

            // allows us to navigate to the map view
            MapView()
                .environmentObject(model)
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            // allows us to navigate to the order info view, where our current order info is displayed
            OrderInfoView()
                .environmentObject(model)
                .tabItem {
                    Label("Order", systemImage: "doc.text")
                }
        }
    }
    
    // Search Related Views
    
    /*
     Subview: Contains both the search bar for the user to look up specific restaurants,
     as well as the options button for changing how the restaurants are sorted
     */
    private var searchSection: some View {
        Section {
            HStack {
                searchField
                optionsButton
            }
        }
    }
    
    /*
     Subview: Search bar for restaurant look-up
     Whatever the user types into the search bar will be stored in the string "search"
     */
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search...", text: $search)
        }
    }

    /*
     Subview: The options button will toggle our menu for selecting how the restaurants are sorted
     The sorting types are stored in our UserInfo class
     Selecting an option from this menu changes the sortType, which is the current method of sorting displayed to the user
     */
    private var optionsButton: some View {
        Button(action: {
            showingOptions.toggle()
        }) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.gray)
                .font(.title)
        }
        .confirmationDialog("Sort by...", isPresented: $showingOptions, titleVisibility: .visible) {
            ForEach(UserInfo.sortTypes, id: \.self) { type in
                Button(type) {
                    UserInfo.sortType = type
                }
            }
        }
    }
    //
    
    // Restaurant Related Views
    
    /*
     Subview: This view will display each restaurant in sorted order and provides the option to navigate to a restaurant's detail view, providing more information
     We pass in the restaurant ID for the detail view in order to state which restaurant to display details for
     This view relies on the filterRestaurants() function to receive the restaurants in sorted order
     */
    private var restaurantSection: some View {
        Section {
            let filtered = filterRestaurants()
            ForEach(filtered) { restaurant in
                NavigationLink(destination: RestaurantDetailView(id: restaurant.id).environmentObject(model)) {
                    restaurantRow(for: restaurant)
                }
            }
        }
    }
    
    /*
     Function: returns an array of restaurants which matches the search field text and is sorted by the selected search type
     sorted() comparison definition can be seen in Restaurant class
     */
    private func filterRestaurants() -> [Restaurant] {
        
        let filteredBySearch: [Restaurant]
        
        // includes only restaurants with names contained in the search field
        if search.isEmpty {
            filteredBySearch = Array(model.restaurants.values)
        }
        else {
            filteredBySearch = model.restaurants.values.filter { restaurant in
                return restaurant.name.lowercased().contains(search.lowercased())
            }
        }
        
        // sorts filtered restaurants by the current sort type
        switch UserInfo.sortType {
        case UserInfo.sortTypes[0]:
            // uses default comparison function defined in restaurant class
            return filteredBySearch.sorted()
        case UserInfo.sortTypes[1]:
            return filteredBySearch.sorted(by: { $0.waitTime < $1.waitTime })
        case UserInfo.sortTypes[2]:
            return filteredBySearch.sorted(by: { $0.distanceAway < $1.distanceAway })
        default:
            return filteredBySearch
        }

    }

    /*
     Subview: Format for the info displayed with each restaurant entry
     Currently includes: name, wait time, and distance away
     Relies on waitTimeView for further formatting of information
     */
    private func restaurantRow(for restaurant: Restaurant) -> some View {
        HStack {
            Text(restaurant.name)
            Spacer()
            VStack(alignment: .trailing) {
                waitTimeView(for: restaurant)
                Text("\(restaurant.distanceAsString()) mi")
            }
        }
    }
    
    /*
     Subview: Formats our wait time info in a restaurant entry
     Relies on waitTimeColor
     */
    private func waitTimeView(for restaurant: Restaurant) -> some View {
        
        let waitTimeColor = waitTimeColor(for: restaurant)
        
        // Group is used here to provide a consistent return type for Swift
        return Group {
            // display time and time icon if open
            if restaurant.isOpen {
                HStack {
                    Text("\(restaurant.waitTime)")
                    Image(systemName: "timer")
                }
                .foregroundColor(waitTimeColor)
            }
            // display closed message if not open
            else {
                Text("Closed")
                    .foregroundColor(.gray)
            }
        }
    }

    /*
     Function: Decides color to display wait time in
     If wait time is under 10, it is considered fast, so green
     If wait time is under 30, it is considered medium, so orange
     If wait time is 30 or above, it is considered slow, so red
     */
    private func waitTimeColor(for restaurant: Restaurant) -> Color {
        // Define thresholds for wait time speeds (in minutes)
        let lowThreshold = 10
        let mediumThreshold = 30
        
        if restaurant.waitTime < lowThreshold {
            return .green
        } else if restaurant.waitTime < mediumThreshold {
            return .orange
        } else {
            return .red
        }
    }
    //
    
    // Data Loading
    //    private func loadInitialData() async {
    //        model.locationManager.checkIfLocationServicesIsEnabled()
    //        await loadData()
    //    }
    //
    
    func loadData() async {

        model.restaurants = [
            "001": Restaurant(id: "001", name: "Subway", description: "This is a test for the view. *Insert Name* makes garbage food that tastes absolutely amazing. Hands-down the best fastfood joint you can go to!", openHour: 6, openMinute: 0, closeHour: 2, closeMinute: 00, latitude: 32.881398208652115, longitude: -117.23520934672317, waitTime: 28, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 8, money: 1),
            "002": Restaurant(id: "002", name: "Panda Express", description: "This is a test for the view. *Insert Name* makes garbage food that tastes absolutely amazing. Hands-down the best fastfood joint you can go to!", openHour: 9, openMinute: 50, closeHour: 22, closeMinute: 30, latitude: 32.884638, longitude: -117.239104, waitTime: 5, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 8, money: 1),
            "003": Restaurant(id: "003", name: "Burger King", description: "This is a test for the view. *Insert name* makes garbage food that tastes absolutely amazing. Hands-down the best fastfood joint you can go to!", openHour: 6, openMinute: 30, closeHour: 1, closeMinute: 0, latitude: 32.8809679784332, longitude: -117.23547474701675, waitTime: 8, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 3, money: 1),
            "004": Restaurant(id: "004", name: "Triton Grill", description: "Located in Muir College on campus. We feature made-to-order sushi, an expansive salad and deli bar, grill and cantina specials, as well as, a decadent dessert station.", openHour: 7, openMinute: 0, closeHour: 1, closeMinute: 0, latitude: 32.88076184401626, longitude: -117.2430254489795, waitTime: 8, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 12, money: 2),
            "005": Restaurant(id: "005", name: "Lemongrass", description: "Located in Muir College on campus. We feature made-to-order sushi, an expansive salad and deli bar, grill and cantina specials, as well as, a decadent dessert station.", openHour: 7, openMinute: 0, closeHour: 1, closeMinute: 0, latitude: 32.8819619, longitude: -117.24311, waitTime: 5, menuItems: ["Food 1", "Food 2", "Food 3", "Food 4", "Food 5"], numInLine: 12, money: 2)
        ]
        
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

// HStack Styling options for restaurant listings
// option 1
//      Text(restaurant.name)
//      Spacer()
//      Image(systemName: "timer")
//      Text("\(restaurant.waitTime)")
//      //Spacer()
//      HStack {
//          Spacer()
//          Text("\(restaurant.distanceAsString()) mi")
//      }
//      .frame(width: 70)

// option 2
//      HStack {
//          Text(restaurant.name)
//          Spacer()
//      }
//      .frame(width: 150)
//      Image(systemName: "timer")
//      Text("\(restaurant.waitTime)")
//      Spacer()
//      Text("\(restaurant.distanceAsString()) mi")

