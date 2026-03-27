//
//  DepartmentViewModel.swift
//  LinphoneApp
//
//  Created by hvn-dyan on 25/3/26.
//

import Foundation

final class DepartmentViewModel: ObservableObject {

    private struct DepartmentsContactResponse: Codable {
        let success: Bool
        let code: Int
        let data: [Department]
    }
    
  
    
    private struct DeptUsersPage: Codable {
        let items: [DeptUserItem]
        let page: Int
        let limit: Int
        let totalPages: Int
        let totalCount: Int
        let hasPreviousPage: Bool
        let hasNextPage: Bool
    }
    
    private struct DeptUsersResponse: Codable {
        let success: Bool
        let code: Int
        let data: DeptUsersPage
    }
    
    @Published var departments: [Department] = []
    @Published private(set) var isLoading: Bool = false

    @Published var currentSelectDept: [Department] = [] {
        didSet {
            recomputeVisibleDepartments()
            fetchDeptUserContactForCurrentSelection()
        }
    }
    static let serverBaseUrl = "https://sp.22792.me:8087"

    @Published private(set) var visibleDepartments: [Department] = []
    @Published private(set) var deptUsers: [DeptUserItem] = []
    @Published private(set) var searchDeptUserResult: [DeptUserItem] = []
    
    /// Debounce work item cho search
    private var searchDebounceWorkItem: DispatchWorkItem?

    // Pagination - dept users
    private var deptPage: Int = 1
    private var deptCurrentCd: String = ""
    @Published private(set) var deptHasNextPage: Bool = false

    // Pagination - search
    private var searchPage: Int = 1
    private var lastSearchKeyword: String = ""
    @Published private(set) var searchHasNextPage: Bool = false

    @Published private(set) var isLoadingMore: Bool = false
    private let contactsManager = ContactsManager.shared

    
    func fetchDepartmentsContact() {
        DispatchQueue.main.async { self.isLoading = true }
        guard let url = URL(string: "\(Self.serverBaseUrl)/api/echo-departments/tree") else {
            Log.error("[DepartmentViewModel] Invalid server URL")
            DispatchQueue.main.async { self.isLoading = false }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                Log.error("[DepartmentViewModel] fetchDepartmentsContact failed: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                Log.error("[DepartmentViewModel] fetchDepartmentsContact invalid response")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            guard (200...299).contains(http.statusCode) else {
                Log.error("[DepartmentViewModel] fetchDepartmentsContact status=\(http.statusCode)")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            guard let data = data else {
                Log.error("[DepartmentViewModel] fetchDepartmentsContact empty body")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            
            let decoder = JSONDecoder()
            guard let decoded = try? decoder.decode(DepartmentsContactResponse.self, from: data) else {
                Log.error("[DepartmentViewModel] fetchDepartmentsContact decode failed")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            
            DispatchQueue.main.async {
                self.departments = decoded.data
                self.recomputeVisibleDepartments()
                self.isLoading = false
            }
        }.resume()
    }
    

  
    func fetchDeptUserContact(deptCds: String) {
        deptCurrentCd = deptCds
        deptPage = 1
        deptHasNextPage = false
        DispatchQueue.main.async { self.deptUsers = [] }
        fetchDeptUsersPage(deptCds: deptCds, page: 1, isLoadMore: false)
    }

    func loadMoreDeptUsers() {
        guard deptHasNextPage, !isLoadingMore, !isLoading else { return }
        guard !deptCurrentCd.isEmpty else { return }
        fetchDeptUsersPage(deptCds: deptCurrentCd, page: deptPage + 1, isLoadMore: true)
    }

    private func fetchDeptUsersPage(deptCds: String, page: Int, isLoadMore: Bool) {
        DispatchQueue.main.async {
            if isLoadMore { self.isLoadingMore = true } else { self.isLoading = true }
        }
        guard var components = URLComponents(string: "\(Self.serverBaseUrl)/api/echo-users") else {
            Log.error("[DepartmentViewModel] Invalid echo-users URL")
            DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
            return
        }

        components.queryItems = [
            URLQueryItem(name: "page",    value: String(page)),
            URLQueryItem(name: "limit",   value: "12"),
            URLQueryItem(name: "all",     value: "false"),
            URLQueryItem(name: "deptCds", value: deptCds),
            URLQueryItem(name: "order",   value: "DESC")
        ]

        guard let url = components.url else {
            Log.error("[DepartmentViewModel] Failed to build echo-users URL")
            DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                Log.error("[DepartmentViewModel] fetchDeptUsersPage failed: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }
            guard let http = response as? HTTPURLResponse else {
                Log.error("[DepartmentViewModel] fetchDeptUsersPage invalid response")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }
            guard (200...299).contains(http.statusCode) else {
                Log.error("[DepartmentViewModel] fetchDeptUsersPage status=\(http.statusCode)")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }
            guard let data = data else {
                Log.error("[DepartmentViewModel] fetchDeptUsersPage empty body")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }

            let decoder = JSONDecoder()
            guard let decoded = try? decoder.decode(DeptUsersResponse.self, from: data) else {
                Log.error("[DepartmentViewModel] fetchDeptUsersPage decode failed")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }

            DispatchQueue.main.async {
                if isLoadMore {
                    self.deptUsers.append(contentsOf: decoded.data.items)
                    self.isLoadingMore = false
                } else {
                    self.deptUsers = decoded.data.items
                    self.isLoading = false
                }
                self.deptPage = page
                self.deptHasNextPage = decoded.data.hasNextPage
            }
        }.resume()
    }
    

    func searchContact(with keyword: String) {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchDebounceWorkItem?.cancel()
            searchDebounceWorkItem = nil
            DispatchQueue.main.async {
                self.searchDeptUserResult = []
                self.isLoading = false
            }
            return
        }
        
        isLoading = true
        
        // cancel debounce
        searchDebounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearchContact(keyword: keyword)
        }
        searchDebounceWorkItem = workItem
        
        // Delay 2s to auto search
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
    
    private func performSearchContact(keyword: String) {
        lastSearchKeyword = keyword
        searchPage = 1
        searchHasNextPage = false
        DispatchQueue.main.async { self.searchDeptUserResult = [] }
        fetchSearchPage(keyword: keyword, page: 1, isLoadMore: false)
    }

    func loadMoreSearchResults() {
        guard searchHasNextPage, !isLoadingMore, !isLoading else { return }
        guard !lastSearchKeyword.isEmpty else { return }
        fetchSearchPage(keyword: lastSearchKeyword, page: searchPage + 1, isLoadMore: true)
    }

    private func fetchSearchPage(keyword: String, page: Int, isLoadMore: Bool) {
        guard var components = URLComponents(string: "\(Self.serverBaseUrl)/api/echo-users") else {
            Log.error("[DepartmentViewModel] Invalid echo-users URL for search")
            return
        }

        components.queryItems = [
            URLQueryItem(name: "page",   value: String(page)),
            URLQueryItem(name: "limit",  value: "16"),
            URLQueryItem(name: "all",    value: "false"),
            URLQueryItem(name: "search", value: keyword),
            URLQueryItem(name: "order",  value: "DESC")
        ]

        guard let url = components.url else {
            Log.error("[DepartmentViewModel] Failed to build search URL")
            return
        }

        DispatchQueue.main.async {
            if isLoadMore { self.isLoadingMore = true } else { self.isLoading = true }
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                Log.error("[DepartmentViewModel] fetchSearchPage failed: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }
            guard let http = response as? HTTPURLResponse else {
                Log.error("[DepartmentViewModel] fetchSearchPage invalid response")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }
            guard (200...299).contains(http.statusCode) else {
                Log.error("[DepartmentViewModel] fetchSearchPage status=\(http.statusCode)")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }
            guard let data = data else {
                Log.error("[DepartmentViewModel] fetchSearchPage empty body")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }

            let decoder = JSONDecoder()
            guard let decoded = try? decoder.decode(DeptUsersResponse.self, from: data) else {
                Log.error("[DepartmentViewModel] fetchSearchPage decode failed")
                DispatchQueue.main.async { self.isLoading = false; self.isLoadingMore = false }
                return
            }

            DispatchQueue.main.async {
                if isLoadMore {
                    self.searchDeptUserResult.append(contentsOf: decoded.data.items)
                    self.isLoadingMore = false
                } else {
                    self.searchDeptUserResult = decoded.data.items
                    self.isLoading = false
                }
                self.searchPage = page
                self.searchHasNextPage = decoded.data.hasNextPage
            }
        }.resume()
    }
    

    func setCurrentDept(_ dept: Department) {
        currentSelectDept.append(dept)
        recomputeVisibleDepartments()
    }

    func popToDept(at index: Int) {
        guard index >= 0 else { return }
        guard index < currentSelectDept.count else { return }
        currentSelectDept = Array(currentSelectDept.prefix(index + 1))
        recomputeVisibleDepartments()
    }

    func resetToRoot() {
        currentSelectDept.removeAll()
        recomputeVisibleDepartments()
    }

    private func recomputeVisibleDepartments() {
        if currentSelectDept.isEmpty {
            visibleDepartments = departments
        } else {
            visibleDepartments = currentSelectDept.last?.children ?? []
        }
    }
    
    private func fetchDeptUserContactForCurrentSelection() {
        guard let deptCd = currentSelectDept.last?.deptCd else {
            deptUsers = []
            return
        }
        fetchDeptUserContact(deptCds: deptCd)
    }
    
    func addUserToContacts(_ user: DeptUserItem, completion: (() -> Void)? = nil) {
        let displayName = user.userNm
        let generatedImage = contactsManager.textToImage(firstName: displayName, lastName: "")
        
        var phones: [PhoneNumber] = []
        if let mobile = user.mobile, !mobile.isEmpty {
            phones.append(PhoneNumber(numLabel: "mobile", num: mobile))
        }
        if let officeTel = user.officeTel, !officeTel.isEmpty {
            phones.append(PhoneNumber(numLabel: "work", num: officeTel))
        }
        
        let contact = Contact(
            identifier: UUID().uuidString,
            firstName: displayName,
            lastName: "",
            organizationName: user.compNm ?? "",
            jobTitle: user.duty ?? "",
            displayName: displayName,
            sipAddresses: [],
            phoneNumbers: phones,
            imageData: ""
        )
        
        contactsManager.saveImage(
            image: generatedImage,
            name: displayName,
            prefix: "-default",
            contact: contact,
            linphoneFriend: contactsManager.linphoneAddressBookFriendList,
            existingFriend: nil
        ) {
            MagicSearchSingleton.shared.searchForContacts()
            completion?()
        }
    }

}
