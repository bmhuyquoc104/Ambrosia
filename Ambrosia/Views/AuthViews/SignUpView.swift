//
//  SignUpView.swift
//  UserLoginWithFirebase
//
//  Created by Tom Huynh on 9/3/22.
//

import SwiftUI
import Firebase

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var email = ""
    @State var password = ""
    @State var passwordConfirmation = ""
    
    @State private var showSignUpMessage = false
    @State private var signUpMessage = ""
    @State var signUpSuccess = false
    
    @FocusState private var emailIsFocused : Bool
    @FocusState private var passwordIsFocused : Bool
    @FocusState private var confirmPasswordIsFocused : Bool
    
    var body: some View {
        ZStack (alignment: .center) {
            VStack (spacing: 30) {
                
                VStack (spacing: 10) {
                    Group {
                        Text("AMBROSIA")
                            .font(Font(UIFont(name: "Chalkboard SE Bold", size: Constants.APP_NAME_LARGE_SIZE)! as CTFont))
                        
                        Text("Join us for good meals !")
                            .font(Font(UIFont(name: "Chalkboard SE", size: Constants.APP_NAME_LARGE_SIZE-20)! as CTFont))
                    }
                    
                    // MARK: CAT GIF
                    GifView(name: "cat-eat")                            .frame(width: 130, height: 110)
                }
                
                
                VStack (spacing: 10){
                    
                    // Sign up fields to sign up for a new account
                    Group {
                        TextField("Email", text: $email)
                            .modifier(TextFieldModifier())
                            .focused($emailIsFocused)
                            .border(Color(uiColor: Constants.PRIMARY_COLOR_UI), width: emailIsFocused ? 1 : 0)
                        SecureField("Password", text: $password)
                            .modifier(TextFieldModifier())
                            .focused($passwordIsFocused)
                            .border(Color(uiColor: Constants.PRIMARY_COLOR_UI), width: passwordIsFocused ? 1 : 0)
                        SecureField("Confirm Password", text: $passwordConfirmation)
                            .modifier(TextFieldModifier())
                            .focused($confirmPasswordIsFocused)
                            .border(passwordConfirmation != password ? Color.red : Color(uiColor: Constants.PRIMARY_COLOR_UI), width: (passwordConfirmation != password || confirmPasswordIsFocused) ? 1 : 0)
                    }
                    .multilineTextAlignment(.leading)
                    
                    // Sign up message after pressing the sign up button
                    if (showSignUpMessage) {
                        Text(signUpMessage)
                            .foregroundColor(signUpSuccess ? .green : .red)
                    }
                }
                
                VStack (spacing: 10) {
                    
                    // Sign up button
                    Button(action: {
                        signUp()
                        showSignUpMessage = true
                    }) {
                        Text("Sign Up")
                            .bold()
                    }
                    .buttonStyle(ButtonStylePrimary())
                    
                    
                    // Button to dismiss sign up sheet and go back to sign in page
                    Button {
                        dismiss()
                    } label: {
                        Text("Back to Sign In Page")
                    }
                }
            }
            .padding(.vertical, Constants.FORM_PADDING_VERTICAL)
            .padding(.horizontal, Constants.FORM_PADDING_HORIZAONTAL)
            .multilineTextAlignment(.center)
            .foregroundColor(Constants.PRIMARY_COLOR)
            
        }
        .background(.white)
        .frame(minWidth: Constants.FIELD_MIN_WIDTH, maxWidth: Constants.FIELD_MAX_WIDTH)
        .cornerRadius(Constants.CONRNER_RADIUS)
//        .shadow(color: Color("Shadow"), radius: 6.0, x: 2, y: 2)
        
    }

    // Sign up function to use Firebase to create a new user account in Firebase
    func signUp() {
        signUpSuccess = false
        if (email == "" || password == "" || passwordConfirmation == "") {
            signUpMessage = "Please fill in all the fields"
        }
        else if (passwordConfirmation != password) {
            signUpMessage = "Confirm password doesn't match"
        }
        else {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    let msg = error?.localizedDescription ?? ""
                    if (msg.contains("email address is badly formatted")) {
                        signUpMessage = "Invalid email address"
                    }
                    else if (msg.contains("email address is already in use")) {
                        signUpMessage = "This email address is already in use"
                    }
                    else {
                        signUpMessage = "Sign up unsuccessfully"
                    }
                } else {
                    signUpMessage = "Sign up successfully"
                    signUpSuccess = true
                }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
