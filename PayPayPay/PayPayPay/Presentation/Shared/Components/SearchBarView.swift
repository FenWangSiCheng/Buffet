import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    @State private var isEditing = false

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("", text: $text, onEditingChanged: { editing in
                    isEditing = editing
                })
                .accessibility(label: Text("搜索商品"))

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .accessibility(label: Text("清空搜索"))
                }
            }
            .padding(7)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            if isEditing {
                Button("取消") {
                    text = ""
                    isEditing = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
            }
        }
        .padding(.horizontal, 10)
    }
}
