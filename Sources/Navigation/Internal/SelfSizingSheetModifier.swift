import SwiftUI

struct SelfSizingSheetModifier: ViewModifier {
    @State private var contentHeight: CGFloat?

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            contentHeight = geometry.size.height
                        }
                        .onChange(of: geometry.size.height) { _, newValue in
                            contentHeight = newValue
                        }
                }
            )
            .presentationDetents(contentHeight.map { [.height($0)] } ?? [.medium])
    }
}
