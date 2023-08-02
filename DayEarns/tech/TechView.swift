//
//  TechView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct TechView: View {
    var tech: Technician
    
    var body: some View {
        List {
            Section(content: {
                Text(tech.name)
                if !tech.phone.isEmpty {
                    Text(tech.phone)
                }
                if let email = tech.email {
                    Text(email)
                }
            }, header: {
                Text("profile")
            } )
            Section(content: {
                Text("\(tech.khach.count)  Clients")
            }, header: {
                Text("you gained")
            })
        }//list
    }
}

//struct TechView_Previews: PreviewProvider {
//    static var previews: some View {
//        TechView()
//    }
//}
