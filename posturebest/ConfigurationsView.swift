//
//  ConfigurationsView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import Foundation
import SwiftUI

struct ConfigurationsView: View {
    var body: some View {
        VStack {
            Text("Configurations Page")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("Configurations")
        .background(Color.gray.opacity(0.1).ignoresSafeArea())
    }
}

struct ConfigurationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationsView()
    }
}
