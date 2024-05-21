import SwiftUI

struct ContentView: View {
    @State private var selectedShape: ShapeType = .sphere
    @State private var offset: CGFloat = UIScreen.main.bounds.height / 2
    @State private var drawerState: DrawerState = .closed

    var body: some View {
        ZStack {
            ARViewContainer(selectedShape: $selectedShape).edgesIgnoringSafeArea(.all)
            
            BottomDrawer(offset: $offset, drawerState: $drawerState) {
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
            drawerState = .closed
            offset = UIScreen.main.bounds.height / 2
        }
    }
}

enum DrawerState {
    case closed
    case open
}

struct BottomDrawer<Content: View>: View {
    @Binding var offset: CGFloat
    @Binding var drawerState: DrawerState
    let content: Content

    init(offset: Binding<CGFloat>, drawerState: Binding<DrawerState>, @ViewBuilder content: () -> Content) {
        self._offset = offset
        self._drawerState = drawerState
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                self.content
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height / 2)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
            .offset(y: self.offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if self.drawerState == .closed {
                            self.offset = value.translation.height + (UIScreen.main.bounds.height / 2)
                        } else {
                            self.offset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if self.drawerState == .closed && self.offset < (UIScreen.main.bounds.height / 4) {
                            withAnimation {
                                self.drawerState = .open
                                self.offset = 0
                            }
                        } else if self.drawerState == .open && self.offset > (UIScreen.main.bounds.height / 4) {
                            withAnimation {
                                self.drawerState = .closed
                                self.offset = UIScreen.main.bounds.height / 2
                            }
                        } else {
                            withAnimation {
                                self.offset = self.drawerState == .open ? 0 : UIScreen.main.bounds.height / 2
                            }
                        }
                    }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
