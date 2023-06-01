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
    let hosting = UIHostingController(rootView: content)
    hosting.view.backgroundColor = .clear
    hosting.view.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(hosting.view)
    var constraints: [NSLayoutConstraint] = [
      hosting.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      hosting.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      hosting.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
      hosting.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    ]
    switch axis {
    case .horizontal:
      constraints.append(hosting.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor))
      scrollView.alwaysBounceHorizontal = true
      scrollView.showsHorizontalScrollIndicator = showsScrollIndicator
    case .vertical:
      constraints.append(hosting.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor))
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
