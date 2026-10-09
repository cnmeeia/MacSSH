import SwiftUI

struct CoreGrid: View {
    let perCore: [Double]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 12)], spacing: 12) {
            // A host's core count never changes, so the index is a stable identity here.
            ForEach(perCore.indices, id: \.self) { index in
                CoreCell(index: index, usage: perCore[index])
            }
        }
    }
}
