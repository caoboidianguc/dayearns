//
//  TagView.swift
//  DayEarns
//
//  Created by Jubi on 3/6/24.
//

import SwiftUI

struct TagView: View {
    @State private var tagName = ""
    @Binding var khach: Khach
    
    var body: some View {
        TextField("Tag's name", text: $tagName)
    }
}

//#Preview {
//    TagView()
//}
