//
//  ContentView.swift
//  Ice Cream
//
//  Created by Bethany on 2025/3/5.
//
import SwiftUI

struct Platform: Hashable {
    var name: String
    let color: Color
    let icon: String
}

struct ContentView: View {
    let platforms: [Platform] = [
        .init(name: "Recipes", color: .pink, icon: "book.pages"),
        .init(name: "Calculator", color: .blue, icon: "plus.forwardslash.minus"),
        .init(name: "Budget", color: .green, icon: "dollarsign.circle")
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                // Main Container - No ScrollView needed
                VStack(spacing: h * 0.05) {
                    
                    // 1. Text moved to the top
                    VStack(spacing: h * 0.01) {
                        Text("Let's Make Some Ice Cream!")
                            .font(.system(size: min(w * 0.05, h * 0.06), weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text("Pick a tool to get started")
                            .font(.system(size: min(w * 0.02, h * 0.03)))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, h * 0.05)
                    
                    // 2. Image + Buttons Overlay
                    ZStack {
                        Image("Home Page Strawberry Ice Cream")
                            .resizable()
                            .scaledToFill()
                            .frame(width: w * 0.9, height: h * 0.7) // Takes up 70% of screen height
                            .clipShape(RoundedRectangle(cornerRadius: w * 0.03))
                            .overlay(
                                // Darken the image slightly so buttons are readable
                                RoundedRectangle(cornerRadius: w * 0.03)
                                    .fill(Color.black.opacity(0.2))
                            )
                            .shadow(radius: 10)
                        
                        // 3. Buttons centered on top of the image
                        VStack(spacing: h * 0.02) {
                            ForEach(platforms, id: \.name) { platform in
                                NavigationLink(value: platform) {
                                    PlatformCard(platform: platform, screenWidth: w, screenHeight: h)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, w * 0.1)
                    }
                    .frame(width: w * 0.9, height: h * 0.7)
                    
                    Spacer(minLength: 0)
                }
                .frame(width: w, height: h)
            }
            .background(Color(red: 0.95, green: 0.98, blue: 0.95))
            .navigationTitle("SweetLogic")
            .navigationDestination(for: Platform.self) { platform in
                // Connecting to the views
                Group {
                    switch platform.name {
                    case "Recipes": Recipes()
                    case "Calculator": Calculator()
                    case "Budget": Budget()
                    default: Text("Unknown Page")
                    }
                }
            }
        }
    }
}

struct PlatformCard: View {
    let platform: Platform
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(platform.color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: platform.icon)
                    .font(.title3)
                    .foregroundColor(platform.color)
            }
            
            Text(platform.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}
