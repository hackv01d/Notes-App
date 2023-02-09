//
//  NotesScreenViewController.swift
//  Notes
//
//  Created by Ivan Semenov on 09.02.2023.
//

import UIKit
import SnapKit

class NotesScreenViewController: UIViewController {
    
    private let headerLabel = UILabel()
    private let addNoteButton = UIButton(type: .system)
    
    lazy private var notesCollection: UICollectionView = {
        let layout = NoteLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let viewModel: NotesScreenViewModel
    
    init(with viewModel: NotesScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    private func setup() {
        setupSuperView()
        setupHeaderLabel()
        setupNotesCollection()
        setupAddNoteButton()
    }
    
    private func setupSuperView() {
        view.backgroundColor = .backgroundApp
    }
    
    private func setupHeaderLabel() {
        view.addSubview(headerLabel)
        
        headerLabel.text = viewModel.textForHeaderLabel
        headerLabel.textColor = .headerText
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(60)
        }
    }
    
    private func setupNotesCollection() {
        view.addSubview(notesCollection)
        
        notesCollection.backgroundColor = .clear
        notesCollection.clipsToBounds = true
        notesCollection.showsVerticalScrollIndicator = false
        notesCollection.dataSource = self
        notesCollection.delegate = self
        notesCollection.register(NoteViewCell.self, forCellWithReuseIdentifier: NoteViewCell.identifier)
        
        notesCollection.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    private func setupAddNoteButton() {
        view.addSubview(addNoteButton)
        
        addNoteButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addNoteButton.imageView?.layer.transform = CATransform3DMakeScale(1, 1, 1)
        addNoteButton.tintColor = .white
        addNoteButton.backgroundColor = .appColor
        addNoteButton.layer.cornerRadius = 65 / 2
        
        addNoteButton.snp.makeConstraints { make in
            make.height.width.equalTo(65)
            make.trailing.bottom.equalToSuperview().inset(40)
        }
    }
}

extension NotesScreenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteViewCell.identifier, for: indexPath) as? NoteViewCell else {
            return NoteViewCell()
        }
        
        cell.configure(with: viewModel.cellViewModels[indexPath.item])
        return cell
    }
}

extension NotesScreenViewController: UICollectionViewDelegate {
    
}
