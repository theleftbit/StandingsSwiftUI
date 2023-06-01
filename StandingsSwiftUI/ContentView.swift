import SwiftUI

struct ContentView: View {
  
  init(model: ViewModel) {
    self.model = model
  }
  
  let model: ViewModel
  
  @State private var statsOffset: CGPoint = .zero
  
  var body: some View {
    StickyScrollView {
      ForEach(model.leagues, id: \.kind) { league in
        leagueHeader(league)
        ForEach(league.divisions, id: \.name) { division in
          VStack(spacing: 0) {
            divisionHeader(division)
            ForEach(division.teams, id: \.name) { team in
              HStack {
                TeamNameView(team: team)
                  .pinToTheLeadingEdge()
                statsView(team)
              }
              .padding(8)
              Divider()
            }
          }
        }
      }
    }
    .navigationTitle("Standings")
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
    HStack {
      Spacer()
        .frame(width: 8)
      DivisionNameView(division: division)
        .pinToTheLeadingEdge()

      SyncableScrollView($statsOffset) {
        HStack {
          ForEach(model.hydratedStats, id: \.rawValue) { stat in
            DivisionStatView(stat: stat)
              .setDefaultFrameForStat()
          }
        }
      }
    }
    .background(.thinMaterial)
    .sticky()
  }
  
  private func statsView(_ team: ViewModel.Division.Team) -> some View {
    SyncableScrollView($statsOffset) {
      HStack {
        ForEach(model.hydratedStats, id: \.rawValue) { stat in
          if let value = team.stats[stat] {
            StatValueView(value: value)
              .setDefaultFrameForStat()
          }
        }
      }
    }
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
    }
  }
  
  struct StatValueView: View {
    
    let value: ViewModel.Stat.Value
    
    var body: some View {
      ZStack {
        Rectangle()
          .fill(Color.red.gradient)
          .cornerRadius(2)
        Text(value)
      }
      .setDefaultFrameForStat()
    }
  }
}

private extension View {
  
  func setDefaultFrameForStat() -> some View {
    self.frame(width: 50, height: 50)
  }
  
  func pinToTheLeadingEdge() -> some View {
    self
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(width: 180)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ContentView(model: .mock())
    }
  }
}
