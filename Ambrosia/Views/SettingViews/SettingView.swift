//
//  SettingView.swift
//  Ambrosia
//
//  Created by Võ Quốc Huy on 11/09/2022.
//
import SwiftUI
import Firebase

struct SettingView: View {
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var restaurantModel: RestaurantModel
    @State var showEditInfo: Bool = false
    @State var showReviewList: Bool = false
    @State var showReview:Bool = false
    @State var hasAvatar: Bool = false
    @State var showPickImageModal = false
    @State var avatar : Image? = Image("default-avatar")
    

    // for dark light mode
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    // MARK: set theme dark light mode
    func setAppTheme() {
        //MARK: use saved device theme from toggle
        userModel.user.isDarkModeOn = UserDefaultsUtils.shared.getDarkMode()
        changeDarkMode(state: userModel.user.isDarkModeOn)
        //MARK: or use device theme
        if (colorScheme == .dark)
        {
            userModel.user.isDarkModeOn = true
        }
        else {
            userModel.user.isDarkModeOn = false
        }
        changeDarkMode(state: userModel.user.isDarkModeOn)
    }
    func changeDarkMode(state: Bool) {
        (UIApplication.shared.connectedScenes.first as?
            UIWindowScene)?.windows.first!.overrideUserInterfaceStyle = state ? .dark : .light
        UserDefaultsUtils.shared.setDarkMode(enable: state)
    }
    var ToggleTheme: some View {
        Toggle("Dark Mode", isOn: $userModel.user.isDarkModeOn)
            .foregroundColor(Color("TextColor"))
            .onChange(of: userModel.user.isDarkModeOn) { (state) in
            changeDarkMode(state: state)
            userModel.updateUserThemeMode()
        }.labelsHidden()
    }

    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GeneralBackground()
                
                VStack {
                    VStack (spacing: 10) {
                        Spacer()
                        
                        ZStack (alignment: .bottomTrailing) {
                            Group {
//                                if (userModel.user.avatarStr != "") {
//                                    AsyncImage(url: URL(string: userModel.user.avatarStr)) { image in
//                                        image.resizable()
//                                        image.scaledToFill()
//                                        image.modifier(AvatarModifier())
//
//                                    } placeholder: {
//                                        Image("default-avatar")
//                                    }
//                                }
//                                else {
                                    avatar?
                                        .resizable()
                                        .scaledToFill()
                                        .modifier(AvatarModifier())                            }
//                            }
                            
                            Button(action: {
                                showPickImageModal = true
                            }) {
                              Image("camera-icon")
                            }
                        }
                        

                        Text(userModel.user.name != "" ? userModel.user.name : "Ambrosa's Member")
                            .font(Font(UIFont(name: "Chalkboard SE Bold", size: Constants.APP_NAME_LARGE_SIZE-15)! as CTFont))
                            .foregroundColor(.white)
                            .padding(.bottom, geometry.size.height*0.3*0.1)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height*0.3)
                
                    VStack (spacing: 10) {
                        Form {
                            Section(header:
                                      Text("Profile Information")
                                      .font(.system(size: 15))
                                      .fontWeight(.semibold)
                            ) {
                                  HStack {
                                    Text("Email")
                                    Spacer()
                                      Text((Auth.auth().currentUser?.email != "" ? Auth.auth().currentUser?.email : Auth.auth().currentUser?.providerData[0].email) ?? "")
                                  }
                                
                                  HStack {
                                    Text("Date of Birth")
                                    Spacer()
                                      Text(FormatDate.convertDateToString(formatDay: userModel.user.dob))
                                  }
                                
                                  HStack {
                                    Text("Gender")
                                    Spacer()
                                      Text(userModel.user.selectedGender == 0 ? "Male" : "Female")
                                  }
                            }
                        }
                        .font(.system(.body, design: .rounded))
                            
                        Spacer()
                        
                        VStack {
                              // MARK: EDIT INFO BTN
                              Button {
                                  showEditInfo = true

                              } label: {
                                  HStack {
                                      Text("Edit Profile").bold()
                                      Image("edit-icon")
                                  }
                              }
                                  .buttonStyle(ButtonStylePrimary())

                              // MARK: SIGN OUT BTN
                              Button {
                                  // background music
                                  SoundModel.startBackgroundMusic(bckName: "login")
                                  // sound effect
                                  SoundModel.clickCardSound()
                                  userModel.SignOut()
                              } label: {
                                  HStack {
                                      Text("Sign Out").bold()
                                      Image("signout-icon")
                                  }
                                  
                              }
                                  .buttonStyle(ButtonStyleLightPrimary())
                            
                        }
                        .padding(.bottom, geometry.size.height*0.13)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height*0.7)
                    .background(Color("BackgroundSettingView"))
                Button {
                    showReview = true
                } label: {
                    Text("Recent Reivews").foregroundColor(Color("SecondaryColor")).font(.system(size: 14)).bold()
                }.sheet(isPresented: $showReview) {
                    RecentReviews()
                }
                ToggleTheme
                }

            }
            
            if(showPickImageModal) {
                PickImageModal(showPickImageModal: $showPickImageModal, avatar: $avatar)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)
        .onAppear(perform: {
            if (userModel.user.avatarStr != "") {
                if let resourcePath = Bundle.main.resourcePath {
                    let imgName = "userAvatar.png"
                    let path = resourcePath + "/" + imgName
                    PickImageModal.download(url: URL(string: userModel.user.avatarStr)!, toFile: URL(string: path)!, completion: {_ in
                        print("download done")
                    })
                }
                avatar = Image("userAvatar")
            }
        })
        .sheet(isPresented: $showEditInfo) {
            EditInformation()
        }
        
            .sheet(isPresented: $showReviewList) {
            RecentReviews()
        }
            .onAppear(perform: {
            setAppTheme()
        })
    }
    
}
