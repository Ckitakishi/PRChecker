//
//  PRListView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/06.
//

import SwiftUI

struct PRListView: View {
    @EnvironmentObject var filterViewModel: FilterViewModel
    
    @ObservedObject var prListViewModel = PRListViewModel()
    @ObservedObject var myPRManager = MyPRManager.shared

    var body: some View {
        RefreshableScrollView(onRefresh: { completion in
            prListViewModel.getPRList() {
                completion()
            }
        }) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], alignment: .leading, pinnedViews: [.sectionHeaders]) {
                
                if let filteredPRList = myPRManager.prList.filter(filterViewModel.combinedFilter?.filter ?? { _ in true }), !filteredPRList.isEmpty {
                    PRSectionView(name: "You", prList: filteredPRList)
                }
                
                
                ForEach(prListViewModel.watchedPRList, id: \.name) { networkPR in
                    if let filteredPRList = networkPR.pullRequests.filter(filterViewModel.combinedFilter?.filter ?? { _ in true }), !filteredPRList.isEmpty {
                        PRSectionView(name: networkPR.name, prList: filteredPRList)
                    }
                    
                }
            }
            .padding()
            .onAppear {
                prListViewModel.getPRList()
            }
            .onChange(of: prListViewModel.additionalFilters, perform: updateAdditionalFilters(_:))
        }
    }
    
    private func updateAdditionalFilters(_ filters: [String: [Filter]]?) {
        if let labelSection = filterViewModel.sections.first(where: { $0.name == "Labels" }) {
            let combinedFilters = labelSection.filters + (filters?["Labels"] ?? [])
            labelSection.filters = combinedFilters.arrayByRemovingDuplicates().sorted { $0.name < $1.name }
        }
        
        if let repositorySection = filterViewModel.sections.first(where: { $0.name == "Repository" }) {
            let combinedFilters = repositorySection.filters + (filters?["Repository"] ?? [])
            repositorySection.filters = combinedFilters.arrayByRemovingDuplicates().sorted { $0.name < $1.name }
        }
    }
}

struct PRSectionView: View {
    let name: String
    let prList: [AbstractPullRequest]
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Section(header: PRSectionHeaderView(name: name)) {
            ForEach(prList, id: \.id) { pullRequest in
                PullRequestCell(pullRequest: pullRequest)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray3, lineWidth: 1))
                    .onTapGesture {
                        openURL(URL(string: pullRequest.url)!)
                    }
            }
        }
    }
}

struct PRSectionHeaderView: View {
    let name: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 45)
            .foregroundColor(.gray5)
            .overlay(
                Text(name)
                    .font(.title)
                    .bold()
                    .padding(.leading),
                alignment: .leading
            )
    }
}

struct PRListView_Previews: PreviewProvider {
    static var previews: some View {
        PRListView()
    }
}
