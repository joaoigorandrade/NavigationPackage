import SwiftUI

struct SelfSizingSheetModifier: ViewModifier {
    @State private var contentHeight: CGFloat = .zero

    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { newHeight in
                guard newHeight > 0, newHeight != contentHeight else { return }
                withAnimation(.easeInOut(duration: 0.25)) {
                    contentHeight = newHeight
                }
            }
            .presentationDetents(detents)
            .presentationDragIndicator(.visible)
    }

    private var detents: Set<PresentationDetent> {
        contentHeight > 0 ? [.height(contentHeight)] : [.medium]
    }
}
