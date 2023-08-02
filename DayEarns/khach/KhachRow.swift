//
//  KhachRow.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct KhachRow: View {
    var khach: Khach
    
    var mauChon: [Color] = [
        .green,.purple,.accentColor,.blue,.brown,.cyan,.indigo,.mint,.orange,.pink,.red,.teal,.yellow]
//    var mauNgau: Color {
//        let red: Double = CGFloat.random(in: 0...1)
//        let green: Double = CGFloat.random(in: 0...1)
//        let blue: Double = CGFloat.random(in: 0...1)
//        return Color(red: red, green: green, blue: blue)
//    }
    var body: some View {
        HStack {
//            Image(systemName: "person")
//                .font(.title3)
            RoundedRectangle(cornerRadius: 5)
                .fill(khach.today ? mauChon.randomElement()!: .gray)
                .frame(width:35, height: 35)
                .overlay{
                    Text(String(khach.name.first!))
                        .font(.system(size: 27))
                        .foregroundStyle(.background)
                }
                
            VStack(alignment: .leading) {
                HStack {
                    Text(khach.name)
                    Spacer()
                    Text(khach.sdt)
                }
                
                Text(khach.honTuan ? khach.ngay.formatted(.dateTime.month().day().weekday(.wide)) : khach.ngay.formatted(.dateTime.day().weekday(.wide)))
                    .font(khach.schedule ? .title3 : .footnote)
                    .foregroundColor(khach.schedule ? .purple : .secondary)
            }
        }.foregroundColor(khach.today ? mauChon.randomElement() : .gray)
           
    }
   
}

struct KhachRow_Previews: PreviewProvider {
    static var previews: some View {
        KhachRow(khach: khachmau[0]).previewLayout(.fixed(width: 300, height: 50))
            
    }
}
