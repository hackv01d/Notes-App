//
//  NotesScreenViewModel.swift
//  Notes-App
//
//  Created by Ivan Semenov on 09.02.2023.
//

import Foundation
import UIKit

final class NotesScreenViewModel {
    
    // MARK: - Public properties
    
    var didUpdateCollection: (() -> Void)?
    var didUpdateHeader: ((String) -> Void)?
    var didUpdateNoteLayout: ((NoteLayoutType) -> Void)?
    
    var didSwipeCell: ((IndexPath) -> Void)?
    var didDeleteCollectionItems: (([IndexPath]) -> Void)?
    var didGoToNextScreen: ((UIViewController) -> Void)?

    var hideToolbar: (() -> Void)?
    var showReceivedError: ((String) -> Void)?
    var showDeleteNoteAlert: ((String, String) -> Void)?
    
    var cellViewModels: [NoteViewCellViewModel] = []
    
    // MARK: - Private properties
    
    private(set) var noteLayoutType = NoteLayoutType.list
    
    private var indexPathSelectedNote: IndexPath?
    
    private var notes: [Note] = [] {
        didSet {
            cellViewModels = notes.map { NoteViewCellViewModel(titleNote: $0.title,
                                                               textNote: $0.content,
                                                               dateCreated: $0.dateCreated?.format(),
                                                               dateModified: $0.dateModified?.format()) }
        }
    }
    
    // MARK: - Inits
    
    init() {
        getNotes()
    }
    
    // MARK: - Public methods
    
    func createNote() {
        goToEditNote(nil)
    }
    
    func editNote(at index: Int) {
        guard indexPathSelectedNote == nil else {
            indexPathSelectedNote = nil
            hideToolbar?()
            return
        }
        
        let note = notes[index]
        goToEditNote(note)
    }
    
    func setListLayout() {
        noteLayoutType = .list
        didUpdateNoteLayout?(noteLayoutType)
    }
    
    func setGalleryLayout() {
        noteLayoutType = .gallery
        didUpdateNoteLayout?(noteLayoutType)
    }
    
    func updateHeader() {
        let numberOfNotes = notes.count
        let headerText = "\(numberOfNotes) \(numberOfNotes == 1 ? "Note" : "Notes")"
        didUpdateHeader?(headerText)
    }
    
    func swipeNote(with indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        
        indexPathSelectedNote = indexPath
        didSwipeCell?(indexPath)
    }
    
    func shouldDeleteNote() {
        showDeleteNoteAlert?("", "Selected note will be deleted")
    }
    
    func deleteNoteFromHomeScreen() {
        guard let indexPathSelectedNote = indexPathSelectedNote else { return }
        
        notes.remove(at: indexPathSelectedNote.item)
        updateHeader()
        self.indexPathSelectedNote = nil
        didDeleteCollectionItems?([indexPathSelectedNote])
    }
    
    // MARK: - Private methods
    
    private func indexForNote(id: ObjectIdentifier) -> Int {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return 0 }
        return index
    }
    
    private func sortListOfNote() {
        notes = notes.sorted { noteOne, noteTwo in
            guard let dateOne = noteOne.dateModified, let dateTwo = noteTwo.dateModified else { return false }
            return dateOne > dateTwo
        }
    }
    
    private func updateNote(at index: Int) {
        let note = notes[index]
        cellViewModels[index].updateData(titleNote: note.title,
                                         textNote: note.content,
                                         dateModified: note.dateModified?.format())
    }
    
    private func goToEditNote(_ note: Note?) {
        let viewModel = EditNoteViewModel(note: note)
        viewModel.delegate = self
        let viewController = EditNoteViewController(with: viewModel)
        didGoToNextScreen?(viewController)
    }
    
    private func getNotes() {
        NoteService.shared.fetchNotes { result in
            switch result {
            case .success(let downloadedNotes):
                notes = downloadedNotes
                DispatchQueue.main.async { [weak self] in
                    self?.didUpdateCollection?()
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.showReceivedError?(error.errorDescription)
                }
            }
        }
    }
}

// MARK: - EditNoteViewModelDelegate

extension NotesScreenViewModel: EditNoteViewModelDelegate {
    func addNewNoteInCollection(note: Note) {
        notes.insert(note, at: 0)
        updateHeader()
        didUpdateCollection?()
    }
    
    func updateNoteInCollection(with id: ObjectIdentifier) {
        let index = indexForNote(id: id)
        updateNote(at: index)
        sortListOfNote()
        didUpdateCollection?()
    }
    
    func deleteNote(with id: ObjectIdentifier) {
        let index = indexForNote(id: id)
        notes.remove(at: index)
        updateHeader()
        didUpdateCollection?()
    }
    
    func showError(desc: String) {
        showReceivedError?(desc)
    }
}

