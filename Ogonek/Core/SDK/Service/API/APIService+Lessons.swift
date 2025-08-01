//
//  APIService+Lessons.swift
//  Ogonek
//
//  Created by Danila Volkov on 31.07.2025.
//

import Foundation

extension APIService {
    /// Fetch lessons with pagination
    func listLessons(page: Int32? = nil, perPage: Int32? = nil, search: String? = nil, assignee: String? = nil) async throws -> PaginatedLessons {
        try await openAPIClient.fetchLessons(page: page, perPage: perPage, search: search, assignee: assignee)
    }

    /// Fetch a specific lesson by ID
    func fetchLesson(id: String) async throws -> Lesson {
        try await openAPIClient.fetchLesson(id: id)
    }
}
