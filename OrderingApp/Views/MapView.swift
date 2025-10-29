//
//  MapView.swift
//  OrderingApp
//
//  Created by Aaron McCully
//
//  Map annotations
//  I wonder if this is a binding issue again? go back to adins implementation for binding?
//  If permission is not giving (user location isnt registered yet) then compare only looks at wait time, this is why panda express pops up first! You need to make sure the location is loaded and then the indexes are set? Somehow

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var model: ModelData
    @EnvironmentObject var locationManager: LocationManager
    
    // Added shared coords
    @ObservedObject var coordinates = UserInfo.sharedCoords
    
    // view will respond when changes are made to @State vars
    @State var search: String = ""
    
    // Var for moving between map annotations
    // used for keeping track of which map annotation item to transition to
    @State var counter: Int = -1
    
    // resets counter (current restaurant on map) when search input changes
    var bindingSearch: Binding<String> {
        Binding(
            get: { search },
            set: {
                search = $0
                counter = -1
            }
        )
    }
    
    var filteredRestaurants: [Restaurant] {
        model.filterRestaurants(search: search, userLocation: locationManager.userLocation!)
    }
    
    // represents the current region shown on the map screen, this will start at UCSD
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 32.879765,
            longitude: -117.236202),
        span: MKCoordinateSpan(
            latitudeDelta: 0.01,
            longitudeDelta: 0.01)
    )
    
    var body: some View {
        // create navigation stack here?
        ZStack {
            // Binding(get: { coordinates.region }, set: { _ in })
            // $coordinates.region
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: filteredRestaurants) { restaurant in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)) {
                    
                    PlaceAnnotationView(restaurant: restaurant)
                        .environmentObject(model)
                    
                }
            }
            .edgesIgnoringSafeArea(.top)
//            .accentColor(Color(.systemPurple))
            .onAppear {
                if let coordinate = locationManager.userLocation?.coordinate {
                    updateRegion(latitude: coordinate.latitude, longitude: coordinate.longitude)
                }
                else {
                    print("error")
                }
                counter = -1
                
            }
            
            VStack {
                // search bar, see about making same as list screen
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search...", text: bindingSearch)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.thinMaterial).padding(8))
                
                Spacer()
                
                HStack {
                    NavButton(symbolName: "arrow.backward") {
                        withAnimation {
                            guard counter > 0 else { return }
                            counter -= 1
                            updateRegion(latitude: filteredRestaurants[counter].latitude, longitude: filteredRestaurants[counter].longitude)
                        }
                    }
                    Spacer()
                    NavButton(symbolName: "arrow.forward") {
                        withAnimation {
                            guard counter < filteredRestaurants.count - 1 else { return }
                            counter += 1
                            updateRegion(latitude: filteredRestaurants[counter].latitude, longitude: filteredRestaurants[counter].longitude)
                        }
                    }
                }
            }
        }
        
    }

    func updateRegion(latitude: Double, longitude: Double) {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }
    
    struct NavButton: View {
        let symbolName: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action, label: {
                Image(systemName: symbolName)
                    .foregroundColor(Color.white)
                    .font(.system(size: 40))
            })
            .padding(10)
            .background(
                Circle()
                    .foregroundColor(Color(UIColor.systemIndigo))
                    .shadow(color: .black, radius: 2)
            )
            .padding(.bottom, 30)
            .padding(.horizontal, 20)
        }
    }
    
    struct PlaceAnnotationView: View {
        @EnvironmentObject var model: ModelData

        @State private var showingSheet = false
        @State var selectedDetent: PresentationDetent = .fraction(0.25)

        let restaurant: Restaurant

        var body: some View {
            VStack(spacing: 0) {
                // make names have a red border that traces the text (similar to apple maps)
                Text(restaurant.name)
                    .foregroundColor(.white)
                    .padding(2)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.red)
                    )
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
            .onTapGesture {
                showingSheet.toggle()
            }
            .sheet(isPresented: $showingSheet) {
                VStack(alignment: .leading) {
                    NavigationView {
                        RestaurantDetailView(id: restaurant.id)
                            .environmentObject(model)
                            .foregroundColor(.primary)
                            .padding(.top, 25)
                    }
                }
                .presentationDetents([.fraction(0.25), .large], selection: $selectedDetent)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(ModelData())
    }
}
