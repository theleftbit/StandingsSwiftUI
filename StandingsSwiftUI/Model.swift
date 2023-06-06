import SwiftUI

struct ViewModel: Equatable {
  
  let leagues: [League]
  let hydratedStats: [Stat.Kind]
  
  struct League: Equatable, Hashable {
    
    let kind: Kind
    let divisions: [Division]

    enum Kind: Hashable {
      case american
      case national
      
      var title: String {
        switch self {
        case .american:
          return "American"
        case .national:
          return "National"
        }
      }

    }
        
  }
  
  struct Division: Identifiable, Equatable, Hashable {
    let name: String
    let teams: [Team]
    
    var id: String { name }
    
    struct Team: Identifiable, Equatable, Hashable {
      let name: String
      let stats: [Stat.Kind: Stat.Value]
      
      var id: String { name }
      var tag: Int { id.hashValue }
    }
  }
  
  struct Stat: Equatable, Hashable {
    let kind: Kind
    let value: Value
    
    typealias Value = String
    
    enum Kind: String, CaseIterable, Equatable, Hashable {
      case wins
      case losses
      case winningPercent
      case gamesBehind
      case lastTen
      case streak
      case runDifferential
      case homeRecord
      case awayRecord
      case previousGame
      case nextGame
      case eliminationNumber
      
      var title: String {
        switch self {
        case .wins:
          return "W"
        case .losses:
          return "L"
        case .winningPercent:
          return "PCT"
        case .gamesBehind:
          return "GB"
        case .eliminationNumber:
          return "E#"
        case .lastTen:
          return "L10"
        case .streak:
          return "STRK"
        case .runDifferential:
          return "RDIFF"
        case .homeRecord:
          return "HOME"
        case .awayRecord:
          return "AWAY"
        case .previousGame:
          return "LAST GAME"
        case .nextGame:
          return "NEXT GAME"
        }
      }
    }
  }
}

extension ViewModel {
  static func mock() -> ViewModel {
    let allStats = ViewModel.Stat.Kind.allCases
    let alEast = Division(name: "AL East", teams: [
      .init(name: "NY Yankees", stats: generateRandomStats()),
      .init(name: "Baltimore Orioles", stats: generateRandomStats()),
      .init(name: "Tampa Bay", stats: generateRandomStats()),
      .init(name: "Boston Red Sox",  stats: generateRandomStats()),
    ])
    
    let alCentral = Division(name: "AL Central", teams: [
      .init(name: "Minessota Twins", stats: generateRandomStats()),
      .init(name: "Detroit Tigers",  stats: generateRandomStats()),
      .init(name: "Cleveland Guardians", stats: generateRandomStats()),
      .init(name: "Chicago White Sox", stats: generateRandomStats()),
    ])
    let nlEast = Division(name: "NL East", teams: [
      .init(name: "Braves", stats: generateRandomStats()),
      .init(name: "Marlins", stats: generateRandomStats()),
      .init(name: "Mets", stats: generateRandomStats()),
      .init(name: "Phillies",  stats: generateRandomStats()),
    ])
    
    let nlCentral = Division(name: "NL Central", teams: [
      .init(name: "Pirates", stats: generateRandomStats()),
      .init(name: "Brewers",  stats: generateRandomStats()),
      .init(name: "Reds", stats: generateRandomStats()),
      .init(name: "Cubs", stats: generateRandomStats()),
    ])
    return .init(
      leagues: [
        .init(kind: .american, divisions: [alEast, alCentral]),
        .init(kind: .national, divisions: [nlEast, nlCentral]),
      ],
      hydratedStats: allStats
    )
  }
  
  static func generateRandomStats() -> [Stat.Kind: Stat.Value] {
    let allStats = ViewModel.Stat.Kind.allCases
    let tuple = allStats.map { kind in
      (kind, "\(Int.random(in: 0...100))")
    }
    return .init(uniqueKeysWithValues: tuple)
  }
}
