//
//  LoiView.swift
//  DayEarns
//
//  Created by Jubi on 9/7/23.
//

import SwiftUI

struct LoiView: View {
    let loi: Loi
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("small Error!")
                    .font(.title)
                    .padding(.bottom)
                Text(loi.error.localizedDescription)
                    .font(.headline)
                Text(loi.chiTiet)
                    .font(.title)
                    .padding(.top)
            }
//            .background(.ultraThinMaterial)
//            .clipShape()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Dismiss"){
                        dismiss()
                    }
                }
            }
        }
    }//body
}

//#Preview {
//    LoiView()
//}
