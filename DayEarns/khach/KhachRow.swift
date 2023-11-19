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
                .frame(width:42, height: 42)
                .overlay{
                    Text(String(khach.name.first!))
                        .font(.system(size: 35))
                        .foregroundStyle(.background)
                }
                
            HStack {
                VStack(alignment: .leading) {
                    Text(khach.name)
                    Text(khach.sdt)
                        .font(.subheadline)
                }
                Spacer()
//                Text("\(khach.ngay.formatted(.relative(presentation: .numeric)))")
//                .environment(\.calendar, calendar)
                VStack(alignment: .trailing) {
                    Text("")
                    Text(khach.ngay.formatted(.relative(presentation: .numeric)))
                        
                        .font(khach.schedule ? .title2 : .footnote)
                        .foregroundColor(khach.schedule ? .purple : .secondary)
                }
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

