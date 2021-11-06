//
//  PullRequest.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/03.
//

import Foundation
import Apollo
import SwiftUI

enum PRState: String {
    case open = "Open"
    case merged = "Merged"
    
    var color: Color {
        switch self {
        case .open:
            return .green
        case .merged:
            return .orange
        }
    }
}

enum ViewerStatus: String {
    case waiting = "Waiting"
    case commented = "Commented"
    case blocked = "Blocked"
    case approved = "Approved"
    
    var color: Color {
        switch self {
        case .waiting:
            return .orange
        case .commented:
            return .yellow
        case .blocked:
            return .red
        case .approved:
            return .green
        }
    }
}

class PullRequest: ObservableObject {
    struct Header {
        let repoName: String
        let status: PRState
        let title: String
        let targetBranch: String
        let headBranch: String
        
    }
    
    struct Content {
        let author: String
        let additions: String
        let deletions: String
        let commits: String
        let description: String
        let labels: [LabelModel]
    }
    
    struct Footer {
        let status: ViewerStatus
        let createdTime: String
    }
    
    
    let pullRequest: PrInfo

    lazy var headerViewModel: Header = {
        Header(
            repoName: repositoryName,
            status: state,
            title: title,
            targetBranch: targetBranch,
            headBranch: headBranch
        )
    }()
    
    lazy var contentViewModel: Content = {
        Content(
            author: author,
            additions: "+\(lineAdditions)",
            deletions: "-\(lineDeletions)",
            commits: "\(commits.count) commits",
            description: body,
            labels: labels
        )
    }()
    
    lazy var footerViewModel: Footer = {
        Footer(
            status: viewerStatus,
            createdTime: createdAt
        )
    }()
    
    init(pullRequest: PrInfo) {
        self.pullRequest = pullRequest
    }
    
    var id: GraphQLID {
        pullRequest.id
    }
    
    var isRead: Bool {
        pullRequest.isReadByViewer ?? false
    }
    
    var url: String {
        pullRequest.url
    }
    
    var repositoryName: String {
        pullRequest.repository.nameWithOwner
    }
    
    var targetBranch: String {
        pullRequest.baseRefName
    }
    
    var headBranch: String {
        pullRequest.headRefName
    }
    
    var author: String {
        pullRequest.author?.login ?? "Unknown"
    }
    
    var title: String {
        pullRequest.title
    }
    
    var body: String {
        pullRequest.body
    }
    
    var changedFileCount: Int {
        pullRequest.changedFiles
    }
    
    var lineAdditions: Int {
        pullRequest.additions
    }
    
    var lineDeletions: Int {
        pullRequest.deletions
    }
    
    var commits: [GraphQLID] {
        pullRequest.commits.nodes?.compactMap { $0 }.map(\.id) ?? []
    }
    
    var labels: [LabelModel] {
        pullRequest.labels?.nodes?.compactMap { $0 }.map(LabelModel.init) ?? []
    }
    
    var state: PRState {
        switch pullRequest.state {
        case .open:
            return .open
        case .merged:
            return .merged
        default:
            fatalError("This is unreachable because our query won't allow it")
        }
    }
    
    var viewerStatus: ViewerStatus {
        switch pullRequest.viewerLatestReview?.state {
        case .none, .pending, .dismissed:
            return .waiting
        case .approved:
            return .approved
        case .changesRequested:
            return .blocked
        case .commented:
            return .commented
        default:
            assertionFailure("Unknown status: \(String(describing: pullRequest.viewerLatestReview?.state))")
            return .waiting
        }
    }
    
    var mergedAt: String? {
        pullRequest.mergedAt
    }
    
    var createdAt: String {
        pullRequest.createdAt
    }
}

struct LabelModel {
    let labelConnection: PrInfo.Label.Node

    var id: GraphQLID {
        labelConnection.id
    }
    
    var title: String {
        labelConnection.name
    }
    
    var color: Color {
        return .init(hexValue: labelConnection.color)
    }
}
