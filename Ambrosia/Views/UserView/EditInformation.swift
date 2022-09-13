//
//  LoginView.swift
//  Ambrosia
//
//  Created by Khanh Tran Nguyen Ha on 10/09/2022.
//

import SwiftUI
import Firebase

struct EditInformation: View {
    @Environment(\.dismiss) var dismiss
    private var services = FirebaseService.services
    @EnvironmentObject var userModel: FirebaseService
    
    @State var email = ""
    @State var password = ""

    @State var loginSuccess = false

    var body: some View {
        ZStack (alignment: .center) {
            Rectangle()
                .foregroundColor(Constants.PRIMARY_COLOR)
            VStack {
                InformationForm()
                // MARK: LOGIN BUTTON
                Button {
                    guard let userId = Auth.auth().currentUser?.uid else { return }
                    userModel.user.id = userId
                    services.updateUser(user: userModel.user)
                    userModel.isNewUser = false
                    
                } label: {
                    Text("Confirm Changes").bold()
                }.buttonStyle(ButtonStyleWhite())
            }
        }
    }
}

struct EditInformation_Previews: PreviewProvider {
    static var previews: some View {
        EditInformation()
    }
}
