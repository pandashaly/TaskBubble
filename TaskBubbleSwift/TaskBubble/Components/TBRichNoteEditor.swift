import SwiftUI

struct TBRichNoteEditor: View {
    @Binding var text: String
    @ObservedObject var coordinator: RichTextCoordinator
    var showLabel: Bool = true
    var maxWords: Int = 250
    var onExpand: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showLabel {
                HStack {
                    Text("Notes")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(wordCount(text))/\(maxWords)")
                        .font(.caption)
                        .foregroundColor(
                            wordCount(text) >= maxWords ? .red :
                            wordCount(text) >= 200 ? .yellow : .secondary
                        )
                }
            }

            ZStack(alignment: .bottomTrailing) {
                RichTextEditor(text: $text, sharedCoordinator: coordinator)
                    .frame(minHeight: 85, maxHeight: 125)
                    .padding(6)
                    .background(Color.Surface.a10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.22), lineWidth: 1)
                    )

                Button(action: onExpand) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(5)
                        .background(Color.Surface.a20.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .padding(6)
            }
        }
    }
    
    private func wordCount(_ s: String) -> Int {
        s.split { $0.isWhitespace }.count
    }
}
