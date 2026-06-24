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
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(mauRow() ? khach.avatarColor : .gray)
                    .frame(width:42, height: 42)
                    .shadow(radius: 2, x: 1, y: 1)
                    .overlay{
                        if khach.isBirthday {
                            Image(systemName: "birthday.cake.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 35))
                        } else {
                            Text(khach.name.first.map(String.init) ?? "?")
                                .font(.system(size: 35))
                                .foregroundStyle(.background)
                        }
                    }
            }
                
            HStack {
                VStack(alignment: .leading) {
                    Text(khach.name)
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    Text(phone)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    HStack {
                        if mauLayHen {
                            Label("", systemImage: "calendar.badge.clock")
                                .foregroundStyle(.purple)
                                .font(.caption)
                        }
                        Text(hienThoiGiandong)
                            .font(mauLayHen ? .title2 : .footnote)
                            .foregroundColor(mauLayHen ? .purple : .secondary)
                            .lineLimit(1)
                    }
                }
            }
        }.foregroundColor(mauRow() ? khach.avatarColor : .gray)
            .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.background)
                .shadow(radius: 2, x: 1, y: 1)
                .opacity(mauRow() ? 0.1 : 0.05)
        )
            .padding(.horizontal, 4)
            
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

