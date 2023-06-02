import SwiftUI

struct SyncableScrollView<Content: View>: UIViewRepresentable {

  @Binding var offset: CGPoint
  let content: Content
  let axis: Axis.Set
  let showsScrollIndicator: Bool
  public init(_ offset: Binding<CGPoint>, axis: Axis.Set = .horizontal, showsScrollIndicator: Bool = false, @ViewBuilder content: @escaping () -> Content) {
    self._offset = offset
    self.axis = axis
    self.showsScrollIndicator = showsScrollIndicator
    self.content = content()
  }

  func makeUIView(context: Context) -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.backgroundColor = .clear
    scrollView.showsHorizontalScrollIndicator = false
      let hostingConfig = UIHostingConfiguration(content: { content }).margins(.all, 0)
    let hostingView = hostingConfig.makeContentView()
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(hostingView)
    var constraints: [NSLayoutConstraint] = [
      hostingView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      hostingView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    ]
    switch axis {
    case .horizontal:
      constraints.append(hostingView.heightAnchor.constraint(equalTo: scrollView.heightAnchor))
      scrollView.alwaysBounceHorizontal = true
      scrollView.showsHorizontalScrollIndicator = showsScrollIndicator
    case .vertical:
      constraints.append(hostingView.widthAnchor.constraint(equalTo: scrollView.widthAnchor))
      scrollView.alwaysBounceVertical = true
      scrollView.showsVerticalScrollIndicator = showsScrollIndicator
    default:
      break
    }
    NSLayoutConstraint.activate(constraints)
    scrollView.delegate = context.coordinator
    scrollView.setContentOffset(offset, animated: false)
    return scrollView
  }
  
  func updateUIView(_ scrollView: UIScrollView, context: Context) {
    // Allow for deaceleration to be done by the scrollView
    if !scrollView.isDecelerating {
      /// This makes sure that we don't receive the `delegate`
      /// methods while applying the `contentOffset` manually
      let currentDelegate = scrollView.delegate
      scrollView.delegate = nil
      scrollView.setContentOffset(offset, animated: false)
      scrollView.delegate = currentDelegate
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(contentOffset: _offset)
  }
  
  class Coordinator: NSObject, UIScrollViewDelegate {
    let contentOffset: Binding<CGPoint>
    
    init(contentOffset: Binding<CGPoint>) {
      self.contentOffset = contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      contentOffset.wrappedValue = scrollView.contentOffset
    }
  }
}
