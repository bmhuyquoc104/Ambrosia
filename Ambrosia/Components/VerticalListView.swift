//
//  VerticalListView.swift
//  Ambrosia
//
//  Created by Võ Quốc Huy on 17/09/2022.
//

import SwiftUI

struct VerticalListView: View {
    @EnvironmentObject var restaurantModel:RestaurantModel
    @State private var searchText = ""

    var searchResults: [Restaurant] {
        // if the search bar is empty -> show all
        if searchText.isEmpty {
            return restaurantModel.districtRestaurants
        } else {
            // search items that contain either title or address (Case insensitive) from user input
            return restaurantModel.districtRestaurants.filter { $0.title.localizedCaseInsensitiveContains(searchText)
                
            }
        }
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            LazyVStack(spacing: 35) {
                ForEach(0..<searchResults.count, id: \.self) {
                    index in
                    // link to the restaurant detail
                    NavigationLink() {
                            // find the current restaurant and display when the view appear
                            RestaurantDetailView().onAppear {
                                restaurantModel.getCurrentRestaurantByDistance(placeId: searchResults[index].placeId ?? "")
                                restaurantModel.getServiceOptions()
                                restaurantModel.getDiningOptions()
                                restaurantModel.getPlaningOptions()
                                restaurantModel.getPaymentOptions()
                            }
                            
                        } label: {
                            // Card to show restaurant
                            RestaurantCardView(name: searchResults[index].title, rating: searchResults[index].totalScore ?? 5.0, address: searchResults[index].address ?? "", photo_id: searchResults[index].imageUrls?[0] ?? "", total_ratings: searchResults[index].rank ?? 1, distance: searchResults[index].distance)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            SoundModel.clickCardSound()
                        })
                    
                }
            }.padding()
            
        }.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by restaurant's name")
        
        
        // add the search bar and set the mode to always display the search bar
    }
    

}

struct VerticalListView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalListView()
    }
}
