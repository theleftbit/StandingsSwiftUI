import SwiftUI

extension View {
  func sticky() -> some View {
    modifier(Sticky())
  }
}

struct StickyScrollView<T: View>: View {
  
  init(@ViewBuilder contents: () -> T ) {
    self.contents = contents()
  }
  
  let contents: T
  
  @State private var frames: [CGRect] = []
  
  var body: some View {
    ScrollView {
      contents
    }
    .coordinateSpace(name: "container")
    .onPreferenceChange(FramePreference.self) {
      frames = $0.sorted(by: { $0.minY < $1.minY })
    }
    .environment(\.stickyFrames, frames)
  }
}

//MARK: Private

private struct StickyFramesEnvironmenKey: EnvironmentKey {
  static let defaultValue = [CGRect]()
}

private extension EnvironmentValues {
  var stickyFrames: [CGRect] {
    get { self[StickyFramesEnvironmenKey.self] }
    set { self[StickyFramesEnvironmenKey.self] = newValue }
  }
}

private struct FramePreference: PreferenceKey {
  static var defaultValue: [CGRect] = []
  
  static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
    value.append(contentsOf: nextValue())
  }
}

private struct Sticky: ViewModifier {
  
  @Environment(\.stickyFrames) var stickyRects
  @State var frame: CGRect = .zero
  
  var isSticking: Bool {
    frame.minY < 0
  }
  
  var offset: CGFloat {
    guard isSticking else { return 0 }
    var o = -frame.minY
    if let idx = stickyRects.firstIndex(where: { $0.minY > frame.minY && $0.minY < frame.height }) {
      let other = stickyRects[idx]
      o -= frame.height - other.minY
    }
    return o
  }
  
  func body(content: Content) -> some View {
    content
      .offset(y: offset)
      .zIndex(isSticking ? .infinity : 0)
      .background(GeometryReader { proxy in
        let f = proxy.frame(in: .named("container"))
        Color.clear
          .onAppear { frame = f }
          .onChange(of: f) { frame = $0 }
          .preference(key: FramePreference.self, value: [frame])
      })
  }
}
