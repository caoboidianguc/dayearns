//
//  KhachRow.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct KhachRow: View {
    var khach: Khach
    
    var body: some View {
        HStack {
//            Image(systemName: "person")
//                .font(.title3)
            RoundedRectangle(cornerRadius: 5)
                .fill(khach.today ? khach.mauNgauNhien : .gray)
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
//                Text("\(khach.ngay.formatted(.relative(presentation: .numeric)))")
//                .environment(\.calendar, calendar)
                Text(khach.ngay.formatted(.relative(presentation: .numeric)))
                    
                    .font(khach.schedule ? .title2 : .footnote)
                    .foregroundColor(khach.schedule ? .purple : .secondary)
            }
        }.foregroundColor(khach.today ? khach.mauNgauNhien : .gray)
           
    }
    
//    var calendar: Calendar = {
//        var calendar = Calendar.current
//        calendar.locale = .init(identifier: "vi")
//        return calendar
//    }()
    
}

struct KhachRow_Previews: PreviewProvider {
    static var previews: some View {
        KhachRow(khach: khachmau[0]).previewLayout(.fixed(width: 300, height: 50))
            
    }
}

