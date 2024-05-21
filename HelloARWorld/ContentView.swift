import SwiftUI

struct ContentView: View {
    @State private var selectedShape: ShapeType = .sphere
    @State private var offset: CGFloat = UIScreen.main.bounds.height / 2
    @State private var isDrawerOpen = false

    var body: some View {
        ZStack {
            ARViewContainer(selectedShape: $selectedShape).edgesIgnoringSafeArea(.all)
            
            BottomDrawer(offset: $offset, isDrawerOpen: $isDrawerOpen) {
                VStack {
                    Button(action: {
                        selectedShape = .sphere
                        closeDrawer()
                    }) {
                        Text("Sphere")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Button(action: {
                        selectedShape = .box
                        closeDrawer()
                    }) {
                        Text("Box")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Button(action: {
                        selectedShape = .cylinder
                        closeDrawer()
                    }) {
                        Text("Cylinder")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
    }
    
    private func closeDrawer() {
        withAnimation {
            isDrawerOpen = false
            offset = UIScreen.main.bounds.height / 2
        }
    }
}

struct BottomDrawer<Content: View>: View {
    @Binding var offset: CGFloat
    @Binding var isDrawerOpen: Bool
    let content: Content

    init(offset: Binding<CGFloat>, isDrawerOpen: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._offset = offset
        self._isDrawerOpen = isDrawerOpen
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.top, 8)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newOffset = value.translation.height + (self.isDrawerOpen ? 0 : geometry.size.height / 2)
                                if newOffset >= 0 {
                                    self.offset = newOffset
                                }
                            }
                            .onEnded { value in
                                if self.offset < geometry.size.height / 4 {
                                    withAnimation {
                                        self.isDrawerOpen = true
                                        self.offset = 0
                                    }
                                } else {
                                    withAnimation {
                                        self.isDrawerOpen = false
                                        self.offset = geometry.size.height / 2
                                    }
                                }
                            }
                    )
                self.content
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height / 2)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
            .offset(y: self.offset)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
