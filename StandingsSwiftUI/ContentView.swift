import SwiftUI

struct ContentView: View {
  
  init(model: ViewModel) {
    self.model = model
  }
  
  let model: ViewModel
  @StateObject var layoutManager = LayoutManager()
  @State private var statsOffset: CGPoint = .zero
    
  var body: some View {
    StickyScrollView {
      VStack(spacing: 0) {
        ForEach(model.leagues, id: \.kind) { league in
          leagueHeader(league)
          ForEach(league.divisions, id: \.name) { division in
            divisionHeader(division)
            ForEach(division.teams, id: \.name) { team in
              HStack(spacing: 0) {
                TeamNameView(team: team)
                  .pinToTheLeadingEdge()
                teamStatsView(team)
              }
              .padding(8)
              Divider()
            }
          }
        }
      }
    }
    .navigationTitle("Standings")
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private func leagueHeader(_ league: ViewModel.League) -> some View {
    Text(league.kind.title)
      .frame(maxWidth: .infinity)
      .background(.thinMaterial)
      .font(.title)
      .multilineTextAlignment(.leading)
      .sticky()
  }
  
  private func divisionHeader(_ division: ViewModel.Division) -> some View {
    HStack(spacing: 0) {
      Spacer()
        .frame(width: 8)
      DivisionNameView(division: division)
        .pinToTheLeadingEdge()

      SyncableScrollView($statsOffset) {
        HStack(spacing: 0) {
          ForEach(model.hydratedStats, id: \.rawValue) { stat in
            DivisionStatView(stat: stat)
              .applyStatConstraint(stat, layoutManager: layoutManager)
              .border(Color.yellow)
          }
        }
      }
      .id("division-header-\(layoutManager.someSortOfID)")
    }
    .background(.thinMaterial)
    .sticky()
  }
  
  private func teamStatsView(_ team: ViewModel.Division.Team) -> some View {
    SyncableScrollView($statsOffset) {
      HStack(spacing: 0) {
        ForEach(model.hydratedStats, id: \.rawValue) { stat in
          if let value = team.stats[stat] {
            StatValueView(value: value)
              .applyStatConstraint(stat, layoutManager: layoutManager)
              .border(Color.yellow)
          }
        }
      }
    }
    .id("team-\(team.name)-\(layoutManager.someSortOfID)")
  }

  struct TeamNameView: View {
    
    let team: ViewModel.Division.Team
    
    var body: some View {
      Text(team.name)
    }
  }
  
  struct DivisionNameView: View {

    let division: ViewModel.Division

    var body: some View {
      Text(division.name)
        .font(.title)
    }
  }
  
  struct DivisionStatView: View {
    let stat: ViewModel.Stat.Kind
    var body: some View {
      Text(stat.title)
        .padding()
        .background {
          Rectangle()
            .fill(Color.blue.gradient)
            .cornerRadius(2)
        }

    }
  }
  
  struct StatValueView: View {
    
    let value: ViewModel.Stat.Value
    
    var body: some View {
      Text(value)
        .padding()
        .background {
          Rectangle()
            .fill(Color.red.gradient)
            .cornerRadius(2)
        }
    }
  }
}

private struct PinToLeadingEdgeModifier: ViewModifier {
  @ScaledMetric var width: CGFloat = 180
  func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(width: width)
  }

}
private extension View {
  
  func pinToTheLeadingEdge() -> some View {
    modifier(PinToLeadingEdgeModifier())
  }
  
  func applyStatConstraint(_ stat: ViewModel.Stat.Kind, layoutManager: LayoutManager) -> some View {
    unowned let _manager = layoutManager
    /// TODO: See if this can be improved
    switch stat {
    case .wins:
      return self.getBiggerWidth(.init(get: { _manager.widthForWins }, set: { _manager.widthForWins = $0}))
    case .losses:
      return self.getBiggerWidth(.init(get: { _manager.widthForLosses }, set: { _manager.widthForLosses = $0}))
    case .winningPercent:
      return self.getBiggerWidth(.init(get: { _manager.widthForWinningPercent }, set: { _manager.widthForWinningPercent = $0}))
    case .gamesBehind:
      return self.getBiggerWidth(.init(get: { _manager.widthForGamesBehind }, set: { _manager.widthForGamesBehind = $0}))
    case .eliminationNumber:
      return self.getBiggerWidth(.init(get: { _manager.widthFoEliminationNumber }, set: { _manager.widthFoEliminationNumber = $0}))
    case .lastTen:
      return self.getBiggerWidth(.init(get: { _manager.widthForLastTen }, set: { _manager.widthForLastTen = $0}))
    case .streak:
      return self.getBiggerWidth(.init(get: { _manager.widthForStreak }, set: { _manager.widthForStreak = $0}))
    case .runDifferential:
      return self.getBiggerWidth(.init(get: { _manager.widthForRunDifferential }, set: { _manager.widthForRunDifferential = $0}))
    case .homeRecord:
      return self.getBiggerWidth(.init(get: { _manager.widthForHomeRecord }, set: { _manager.widthForHomeRecord = $0}))
    case .awayRecord:
      return self.getBiggerWidth(.init(get: { _manager.widthForAwayRecord }, set: { _manager.widthForAwayRecord = $0}))
    case .previousGame:
      return self.getBiggerWidth(.init(get: { _manager.widthForPreviousGame }, set: { _manager.widthForPreviousGame = $0}))
    case .nextGame:
      return self.getBiggerWidth(.init(get: { _manager.widthFoNextGame }, set: { _manager.widthFoNextGame = $0}))
    }
  }
}

private struct BiggerWidthKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce (value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

private struct WidthModifier: ViewModifier {
  
  @Binding var width: CGFloat
  
  func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { proxy in
          Color.clear
            .preference(key: BiggerWidthKey.self, value: proxy.size.width)
        }.onPreferenceChange(BiggerWidthKey.self) { value in
          if value > $width.wrappedValue {
            $width.wrappedValue = value
            print("Chanding to \(value)")
          }
        }
      )
      .frame(width: width > 0 ? width : nil)
  }
}

private extension View {
  func getBiggerWidth(_ viewSize: Binding<CGFloat>) -> some View {
    modifier(WidthModifier(width: viewSize))
  }
}

class LayoutManager: ObservableObject {
  
  @Published var widthForWins: CGFloat = 0
  @Published var widthForLosses: CGFloat = 0
  @Published var widthForWinningPercent: CGFloat = 0
  @Published var widthForGamesBehind: CGFloat = 0
  @Published var widthForLastTen: CGFloat = 0
  @Published var widthForStreak: CGFloat = 0
  @Published var widthForRunDifferential: CGFloat = 0
  @Published var widthForHomeRecord: CGFloat = 0
  @Published var widthForAwayRecord: CGFloat = 0
  @Published var widthForPreviousGame: CGFloat = 0
  @Published var widthFoNextGame: CGFloat = 0
  @Published var widthFoEliminationNumber: CGFloat = 0
  
  var someSortOfID: String {
    let sum = widthForWins + widthForLosses + widthForWinningPercent + widthForGamesBehind + widthForLastTen + widthForStreak + widthForRunDifferential + widthForHomeRecord + widthForAwayRecord + widthForPreviousGame + widthFoNextGame + widthFoEliminationNumber
    return "\(sum)"
  }
}
  

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ContentView(model: .mock())
    }
  }
}
