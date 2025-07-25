//
//  LessonList.swift
//  Ogonek Swift
//
//  Created by Danila Volkov on 29.04.2025.
//

import Foundation
import SwiftUI

struct LessonListView: View {
    // MARK: - Dependencies
    @Environment(AppState.self) private var appState

    @AppStorage("lastUpdated") var lastUpdated = Date.distantPast.timeIntervalSince1970

    @State private var viewState = ViewState()


    var body: some View {
        NavigationStack {
            if appState.isLoadingLessons {
                ProgressView()
            } else if let error = appState.lessonError {
                ErrorView(error: error) {
                    Task { await appState.loadLessons() }
                }
            } else {
                lessonsList(lessons: appState.lessons) // Now this works
            }
        }
        .navigationTitle(title)
        .environment(\.editMode, $viewState.editMode)
        .alert(isPresented: $viewState.hasError, error: viewState.error) {
            Button("Retry") {
                Task { await appState.loadLessons() }
            }
        }
        .task {
            await appState.loadLessons()
        }
    }

    // MARK: - Private Views
    private func lessonsList(lessons: [Lesson]) -> some View {
        List(selection: $viewState.selection) {
            ForEach(lessons) { lesson in
                LessonRow(lesson: lesson)
            }
            .onDelete(perform: deleteLessons)
        }
        .listStyle(.inset)
        .refreshable {
            await appState.loadLessons()
        }
        .navigationDestination(for: Lesson.self) { lesson in
            LessonDetailView(lesson: lesson)
        }
        .overlay {
            if viewState.isLoading {
                ProgressView("Loading lessons...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Lessons Available",
            systemImage: "book.closed",
            description: Text("Pull to refresh or check your connection")
        )
    }
}

// MARK: - Extensions

extension LessonListView {
    var title: String {
        if viewState.editMode == .active && !viewState.selection.isEmpty {
            return "\(viewState.selection.count) Selected"
        } else {
            return "Lessons"
        }
    }


    private func deleteLessons(offsets _: IndexSet) {
        withAnimation {
            // Implement deletion logic here if needed
            // provider.deleteLessons(at: offsets)
        }
    }
}

// MARK: - ViewState

extension LessonListView {
    struct ViewState {
        var editMode: EditMode = .inactive
        var selectMode: SelectMode = .inactive
        var isLoading = false
        var selection: Set<String> = []
        var error: LessonError?
        var hasError = false
    }
}

// MARK: - Preview
#Preview {
    LessonListView()
        .environment(
            AppState(
                lessonRepo: APILessonRepository(
                    apiService: APIService(downloader: TestDownloader())
                ),
                taskRepo: APITaskRepository(
                    apiService: APIService(downloader: TestDownloader())
                ),
                deckRepo: APIDeckRepository(
                    apiService: APIService(downloader: TestDownloader())
                )
            )
        )
}
