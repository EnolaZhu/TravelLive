//
//  Event.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

class Event {
    let name: String
    let image: String
    let description: String
    
    init(name: String, image: String, description: String) {
        self.name = name
        self.image = image
        self.description = description
    }
    
    // City Factory
    static func buildCities() -> [Event] {
        let ny = Event(name: "New York", image: "newyork", description: "A trip to New York City is the experience of a lifetime. With famous attractions like Times Square, Central Park, the Empire State Building and Yankee Stadium—to name just a few—NYC packs more to see and do into one compact area than any other place on earth. Each of the City’s five boroughs contains its own roster of must-see destinations, great restaurants, cultural hot spots and unforgettable activities. Start planning your trip with the guides on this page.")
        
        let sf = Event(name: "San Francisco", image: "sanfrancisco", description: "A crimson bridge, cable cars, a sparkling bay, and streets lined with elegant Victorian homes—San Francisco is undeniably one of the world’s great cities. Located along the Northern California at the state’s distinctive bend in the coast, the region has an alluring magic that stretches beyond the bay to diverse cities with nightlife and trend-setting cuisine.")
        
        let sea = Event(name: "Seattle", image: "seattle", description: "Blink and it’s changed: Seattle can be that ephemeral. Welcome to a city that pushes the envelope, embraces new trends and plots a path toward the future.")
        
        return [ny, sf, sea]
    }
}

