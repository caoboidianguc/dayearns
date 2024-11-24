//
//  KhachRow.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct KhachRow: View {
    @Binding var khach: Khach
    var phone: String {
        khach.correctPhone(laySo: khach.sdt)
    }
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(mauRow() ? khach.mauNgauNhien : .gray)
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
                    Text(phone)
                        .font(.subheadline)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(hienThoiGiandong)
                        .font(mauLayHen ? .title2 : .footnote)
                        .foregroundColor(mauLayHen ? .purple : .secondary)
                }
            }
        }.foregroundColor(mauRow() ? khach.mauNgauNhien : .gray)
            
    }//body
        
    func mauRow() -> Bool {
        let lich = Calendar.current
        return lich.isDateInToday(khach.ngay) || khach.isBirthday
    }
    var mauLayHen: Bool {
        khach.schedule
    }
    var hienThoiGiandong: String {
        khach.today ? khach.ngay.formatted(.dateTime.hour().minute()) : khach.ngay.formatted(.dateTime.day().weekday())
    }
}

struct KhachRow_Previews: PreviewProvider {
    static var previews: some View {
        KhachRow(khach: .constant(khachmau[0]))
            .previewLayout(.fixed(width: 300, height: 50))
            
    }
}

