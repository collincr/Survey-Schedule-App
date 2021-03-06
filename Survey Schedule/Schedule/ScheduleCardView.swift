//
//  ScheduleCardView.swift
//  Survey Schedule
//
//  Created by Jasper Hsieh on 3/15/20.
//  Copyright © 2020 Jasper Hsieh. All rights reserved.
//

import SwiftUI

struct ScheduleCardView: View {
    @EnvironmentObject private var dynamicRouting: DynamicRouting
    @Environment(\.colorScheme) var colorScheme
//    init(routing dynamicRouting: DynamicRouting){
//        self.dynamicRouting = dynamicRouting
//    }

    var body: some View {
        VStack(){
            Text("Schedule")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                //.lineLimit(2)
                .frame(width: UIScreen.main.bounds.width * 0.8, /*height: 200,*/ alignment: .topLeading)
                .padding(.top)
            HStack(){
                Spacer()
                MasterButtonView().environmentObject(dynamicRouting)
                Spacer()
                AllStationsButtonView().environmentObject(dynamicRouting)
                Spacer()
                Spacer()
                Spacer()
            }.padding(.bottom)
        }
        .frame(width:UIScreen.main.bounds.width * 0.9/*, height: 200*/)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(10)
        .padding(.bottom)

    }
}

//struct ScheduleCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleCardView()
//    }
//}
