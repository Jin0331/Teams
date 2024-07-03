//
//  WorkspaceEditView.swift
//  Teams
//
//  Created by JinwooLee on 7/2/24.
//

import ComposableArchitecture
import SwiftUI
import PhotosUI
import PopupView
import Kingfisher

struct WorkspaceEditView : View {
    
    @State var store : StoreOf<WorkspaceEditFeature>
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing: 20) {
                    PhotosPicker( //https://swiftsenpai.com/development/swiftui-photos-picker/
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            ZStack {
                                if let image = store.selectedImageData, let uiImage = UIImage(data: image) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 70, height: 70)
                                        .cornerRadius(8)
                                        .padding()
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.brandGreen)
                                        .frame(width: 70, height: 70)
                                        .padding()
                                    Image(.workspace)
                                        .resizable()
                                        .frame(width: 48, height: 60)
                                        .offset(y: 5)
                                }
                                
                                Image(.camera)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .offset(x: 30, y: 30)
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    if let image = UIImage(data: data) {
                                        store.send(.pickedImage(image.compressImage(to: 0.95)))
                                    }
                                }
                            }
                        }
                    
                    Text("워크스페이스 이름")
                        .title2()
                        .foregroundStyle(.brandBlack)
                        .padding()
                        .frame(width: 345, height: 24, alignment: .leading)
                    
                    TextField("워크스페이스 이름을 입력하세요 (필수)", text: $store.workspaceName)
                        .bodyRegular()
                        .padding()
                        .frame(width: 345, height: 44, alignment: .leading)
                    
                    Text("워크스페이스 설명")
                        .title2()
                        .foregroundStyle(.brandBlack)
                        .padding()
                        .frame(width: 345, height: 24, alignment: .leading)
                    
                    TextField("워크스페이스를 설명하세요 (옵션)", text: $store.workspaceDescription)
                        .bodyRegular()
                        .padding()
                        .frame(width: 345, height: 44, alignment: .leading)
                    
                    Button("저장") {
                        store.send(.editButtonTapped)
                    }
                    .foregroundStyle(.brandWhite)
                    .frame(width: 345, height: 44)
                    .title2()
                    .background(backgroundForIsActive(store.createButton))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(!store.createButton)
                    
                    Spacer()
                    
                }
                .popup(item: $store.toastPresent) { text in
                    ToastView(text: text.rawValue)
                } customize: {
                    $0.autohideIn(2)
                }
                .navigationBarTitle("워크스페이스 편집", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button {
                            store.send(.dismiss)
                        } label : {
                            Image("Vector")
                        }
                )
                .navigationBarColor(backgroundColor: .brandWhite, titleColor: .brandBlack)
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .onAppear {
                store.send(.onApear)
            }
        }
    }
}
