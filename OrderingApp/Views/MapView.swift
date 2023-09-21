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
    
    // Added shared coords
    @ObservedObject var coordinates = UserInfo.sharedCoords
    
    // view will respond when changes are made to @State vars
    @State var search: String = ""
    
    // Var for moving between map annotations
    // used for keeping track of which map annotation item to transition to
    @State var counter: Int = -1
    
    var body: some View {
        // create navigation stack here?
        ZStack {
            let bindingSearch = Binding<String>(get: {
                self.search
            }, set: {
                self.search = $0
                self.counter = -1
            })
            
            let filtered = search != "" ? model.restaurants.values.sorted().filter { restaurant in restaurant.name.lowercased().contains(search.lowercased())} : model.restaurants.values.sorted()
            // Binding(get: { coordinates.region }, set: { _ in })
            // $coordinates.region
            Map(coordinateRegion: Binding(get: { coordinates.region }, set: { _ in }), showsUserLocation: true, annotationItems: filtered) { restaurant in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)) {
                    
                    PlaceAnnotationView(restaurant: restaurant)
                        .environmentObject(model)
                    
                }
            }
            .edgesIgnoringSafeArea(.top)
            //.accentColor(Color(.systemPurple))
            .onAppear {
                model.locationManager.checkIfLocationServicesIsEnabled()
                counter = -1
            }
            
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search...", text: bindingSearch)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.thinMaterial).padding(8))
                
                Spacer()
                
                HStack {
                    Button(action: {
                        withAnimation {
                            if counter > 0 {
                                counter-=1
                                let restaurantLatitude = filtered[counter].latitude
                                let restaurantLongitude = filtered[counter].longitude
                                coordinates.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: restaurantLatitude, longitude: restaurantLongitude), span: MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005))
                            }
                        }
                    }, label: {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(Color.white)
                            .font(.title)
                        Text("Prev")
                            .foregroundColor(Color.white)
                            .font(.title)
                    })
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(UIColor.systemIndigo))
                            .shadow(color: .black, radius: 2)
                    )
                    .padding(.bottom, 30)
                    .padding(.leading, 20)
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation {
                                if counter < filtered.count-1 {
                                    counter+=1
                                    let restaurantLatitude = filtered[counter].latitude
                                    let restaurantLongitude = filtered[counter].longitude
                                    coordinates.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: restaurantLatitude, longitude: restaurantLongitude), span: MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005))
                                }
                            }
                        }, label: {
                            Text("Next")
                                .font(.title)
                                .foregroundColor(Color.white)
                            Image(systemName: "arrow.forward")
                                .foregroundColor(Color.white)
                                .font(.title)
                        })
                    }
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(UIColor.systemIndigo))
                            .shadow(color: .black, radius: 2)
                    )
                    .padding(.bottom, 30)
                    .padding(.trailing, 20)
                }
                //.padding(20)
            }
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
//                    Button(action: {
//                        showingSheet.toggle()
//                    }, label: {
//                        if selectedDetent != .fraction(0.25) {
//                            Image(systemName: "xmark")
//                                .foregroundColor(.gray)
//                                .font(.largeTitle)
//                                .padding(30)
//                        }
//                        else {
//                            Spacer()
//                        }
//                    })
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
