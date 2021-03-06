//
//  HavingTroubleButtonView.swift
//  Survey Schedule
//
//  Created by Jasper Hsieh on 3/15/20.
//  Copyright © 2020 Jasper Hsieh. All rights reserved.
//

import SwiftUI

struct HavingTroubleButtonView: View {
    @EnvironmentObject private var dynamicRouting: DynamicRouting
    @State private var showingActionSheet = false
    @State private var showingLoading = false

    var body: some View {
        Button(action: {
            print("click TroubleShooting")
            self.showingActionSheet = true
        }){
            Text("Change of plans?")
                .frame(width: 150)
                .padding()
                .background(Color(hex: "#CB395B"))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("The reason you can't get there"),  buttons:[
                .default(Text("Skip station")){
                    print("Click Not going to visit the station")
                    self.showingLoading = true
                    self.dynamicRouting.handleSkipNextStation()
                },
                .default(Text("End survey today")){
                    print("Click End survey today")
                    self.showingLoading = true
                    self.dynamicRouting.handleEndSurvey()
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showingLoading) {
            LoadingView().environmentObject(self.dynamicRouting)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct HavingTroubleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HavingTroubleButtonView()
    }
}
