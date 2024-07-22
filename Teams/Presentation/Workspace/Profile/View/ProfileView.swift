//
//  ProfileView.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import SwiftUI
import PhotosUI
import PopupView
import Kingfisher
import ComposableArchitecture

struct ProfileView: View {
    
    @State var store : StoreOf<ProfileFeature>
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                Divider().background(.brandWhite)
                    .padding(.bottom, 15)
                
                VStack {
                    switch store.viewType {
                    case .success :
                        ProfileImageView()
                        ProfileFormView()
                    case .loading:
                        VStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.2, anchor: .center)
                                .padding()
                            Spacer()
                        }
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .popup(item: $store.toastPresent) { text in
                ToastView(text: text.rawValue)
            } customize: {
                $0.autohideIn(2)
            }
            .animation(.default, value: store.viewType)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("내 정보 수정", displayMode: .inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        store.send(.goBack)
                    }, label: {
                        Image(.chevron)
                            .resizable()
                            .frame(width: 14, height: 19)
                    })
                }
            }
        }
    }
    
}

extension ProfileView {
    private func ProfileImageView() -> some View {
        return PhotosPicker( //https://swiftsenpai.com/development/swiftui-photos-picker/
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
                            DispatchQueue.main.async {
                                store.send(.buttonTapped(.changeProfileImage(image.compressImage(to: 0.95))))
                            }
                        }
                    }
                }
            }
    }
    
    private func ProfileFormView() -> some View {
        return Form {
            Section {
                HStack(spacing: 5) {
                    Text("이메일")
                        .bodyBold()
                    Spacer()
                    Text(store.email)
                        .bodyRegular()
                        .foregroundStyle(.textSecondary)
                }
                
                HStack(spacing: 5) {
                    Text("닉네임")
                        .bodyBold()
                    Spacer()
                    Text(store.nickname)
                        .bodyRegular()
                        .foregroundStyle(.textSecondary)
                    Image(.chevronRight)
                        .resizable()
                        .frame(width: 22.33, height: 20)
                        .tint(.textSecondary)
                }
                .onTapGesture {
                    store.send(.buttonTapped(.nicknameEditButtonTapped))
                }
                
                HStack(spacing: 5) {
                    Text("연락처")
                        .bodyBold()
                    Spacer()
                    Text(store.phonenumber)
                        .bodyRegular()
                        .foregroundStyle(.textSecondary)
                    Image(.chevronRight)
                        .resizable()
                        .frame(width: 22.33, height: 20)
                        .tint(.textSecondary)
                }
                .onTapGesture {
                    store.send(.buttonTapped(.phonenumberEditButtonTapped))
                }
            }
            
            Section {
                HStack(spacing: 5) {
                    Text("연결된 소셜 계정")
                        .bodyBold()
                    Spacer()
                    
                    if store.provider == "kakao" {
                        Image(.kakaoSmall)
                            .resizable()
                            .frame(width: 20, height: 20)
                    } else if store.provider == "apple" {
                        Image(.appleSmall)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                
                HStack(spacing: 5) {
                    Text("로그아웃")
                        .bodyBold()
                    Spacer()
                }
                .onTapGesture {
                    print("로그아웃")
                }
            }
        }
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
    }
}
