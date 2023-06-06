import SwiftUI

struct StandingsView: View {
  
  init(model: ViewModel) {
    self.model = model
  }
  
  let model: ViewModel
  
  /// Tracks the width of each stats column and makes sure they match across the layout
  @StateObject private var layoutManager = LayoutManager()
  
  /// Tracks the offset of the stats scrollView
  @State private var statsOffset: CGPoint = .zero
  
  @Environment(\.sizeCategory) private var sizeCategory
  
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
    .onChange(of: sizeCategory) { _ in
      layoutManager.reset()
    }
    .navigationTitle("Standings")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct StandingsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      StandingsView(model: .mock())
    }
  }
}

private extension StandingsView {
  
  func leagueHeader(_ league: ViewModel.League) -> some View {
    Text(league.kind.title)
      .frame(maxWidth: .infinity)
      .background(.thinMaterial)
      .font(.title)
      .multilineTextAlignment(.leading)
      .sticky()
  }
  
  func divisionHeader(_ division: ViewModel.Division) -> some View {
    HStack(spacing: 0) {
      
      Spacer()
        .frame(width: 8)
      
      DivisionNameView(division: division)
        .pinToTheLeadingEdge()

      SyncableScrollView($statsOffset) {
        HStack(spacing: 0) {
          ForEach(model.hydratedStats, id: \.rawValue) { stat in
            DivisionStatView(stat: stat)
              .applyWidthConstraint(bindingForStat(stat))
              .border(Color.yellow)
          }
        }
      }
      .id("division-header-\(layoutManager.someSortOfID)")
    }
    .background(.thinMaterial)
    .sticky()
  }
  
  func teamStatsView(_ team: ViewModel.Division.Team) -> some View {
    SyncableScrollView($statsOffset) {
      HStack(spacing: 0) {
        ForEach(model.hydratedStats, id: \.rawValue) { stat in
          if let value = team.stats[stat] {
            StatValueView(value: value)
              .applyWidthConstraint(bindingForStat(stat))
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
  
  func bindingForStat(_ stat: ViewModel.Stat.Kind) -> Binding<CGFloat> {
    switch stat {
    case .wins:
      return $layoutManager.widthForWins
    case .losses:
      return $layoutManager.widthForLosses
    case .winningPercent:
      return $layoutManager.widthForWinningPercent
    case .gamesBehind:
      return $layoutManager.widthForGamesBehind
    case .eliminationNumber:
      return $layoutManager.widthForEliminationNumber
    case .lastTen:
      return $layoutManager.widthForLastTen
    case .streak:
      return $layoutManager.widthForStreak
    case .runDifferential:
      return $layoutManager.widthForRunDifferential
    case .homeRecord:
      return $layoutManager.widthForHomeRecord
    case .awayRecord:
      return $layoutManager.widthForAwayRecord
    case .previousGame:
      return $layoutManager.widthForPreviousGame
    case .nextGame:
      return $layoutManager.widthForNextGame
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
          }
        }
      )
      .frame(width: width > 0 ? width : nil)
  }
}

private extension View {
  func applyWidthConstraint(_ viewSize: Binding<CGFloat>) -> some View {
    modifier(WidthModifier(width: viewSize))
  }
}

private class LayoutManager: ObservableObject {
  
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
  @Published var widthForNextGame: CGFloat = 0
  @Published var widthForEliminationNumber: CGFloat = 0
  
  func reset() {
    self.widthForWins = 0
    self.widthForLosses = 0
    self.widthForWinningPercent = 0
    self.widthForGamesBehind = 0
    self.widthForLastTen = 0
    self.widthForStreak = 0
    self.widthForRunDifferential = 0
    self.widthForHomeRecord = 0
    self.widthForAwayRecord = 0
    self.widthForPreviousGame = 0
    self.widthForNextGame = 0
    self.widthForEliminationNumber = 0
  }
  
  /// SyncableScrollView doesn't seem to re-layout correctly when it's contents change size
  /// Setting an expilicit `.id()` to it, attached to the columns widths makes sure that it will
  /// be re-created when the ID changes, which seems to workaround for now.
  var someSortOfID: String {
    "widthForWins:\(widthForWins)_widthForLosses:\(widthForLosses)_widthForWinningPercent:\(widthForWinningPercent) _widthForGamesBehind:\(widthForGamesBehind)_widthForLastTen:\(widthForLastTen)_widthForStreak:\(widthForStreak)_widthForRunDifferential:\(widthForRunDifferential)_widthForHomeRecord:\(widthForHomeRecord)_widthForAwayRecord:\(widthForAwayRecord)_widthForPreviousGame:\(widthForPreviousGame)_widthFoNextGame:\(widthForNextGame)_ widthFoEliminationNumber:\(widthForEliminationNumber)"
  }
}
