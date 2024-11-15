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
            RoundedRectangle(cornerRadius: 5)
                .fill(mauRow ? khach.mauNgauNhien : .gray)
                .frame(width:42, height: 42)
                .overlay{
                    if khach.isBirthday {
                        Image(systemName: "birthday.cake.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 35))
                    } else {
                        Text(String(khach.name.first!))
                            .font(.system(size: 35))
                            .foregroundStyle(.background)
                    }
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
                        .font(mauLayHen ? .title2 : .footnote)
                        .foregroundColor(mauLayHen ? .purple : .secondary)
                }
            }
        }.foregroundColor(khach.today ? khach.mauNgauNhien : .gray)
           
    }
    var mauRow: Bool {
        khach.today || khach.isBirthday
    }
    var mauLayHen: Bool {
        khach.schedule
    }
//    var calendar: Calendar = {
//        var calendar = Calendar.current
//        calendar.locale = .init(identifier: "vi")
//        return calendar
//    }()
    
}

struct KhachRow_Previews: PreviewProvider {
    static var previews: some View {
        KhachRow(khach: khachmau[0])
            .previewLayout(.fixed(width: 300, height: 50))
            
    }
}

