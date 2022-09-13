//
//  FirebaseService.swift
//  Ambrosia
//
//  Created by William on 12/09/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
class FirebaseService: ObservableObject {
    static let services = FirebaseService()
    @Published var reviewFetch: [Review] = []
    @Published var showSignUpMessage = false
    @Published var signUpMessage = ""
    @Published var signUpSuccess = false
    // Sign up function to use Firebase to create a new user account in Firebase
    func signUp(email: String, password: String, passwordConfirmation: String, user: AuthenticationModel) {
        if (email == "" || password == "" || passwordConfirmation == "") {
            self.signUpMessage = "Please fill in all the fields"
        }
        else if (passwordConfirmation != password) {
            self.signUpMessage = "Confirm password doesn't match"
        }
        else {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    let msg = error?.localizedDescription ?? ""
                    if (msg.contains("email address is badly formatted")) {
                        self.signUpMessage = "Invalid email address"
                    }
                    else if (msg.contains("email address is already in use")) {
                        self.signUpMessage = "This email address is already in use"
                    }
                    else {
                        self.signUpMessage = "Sign up unsuccessfully"
                    }
                } else {
                    self.signUpMessage = "Sign up successfully"
                    guard let userID = authResult?.user.uid else { return }
                    Firestore.firestore().collection("user").document(userID).setData([
                        "name": "Sir",
                        "email": authResult?.user.email ?? ""
                        ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                    user.loginSuccess = true
                    user.isNewUser = true
                    self.signUpSuccess = true

                }
            }
        }
    }
    func updateUser(user: User) {
        Firestore.firestore().collection("user").document(user.id).setData(["name": user.name, "dob": user.dob, "gender": user.selectedGender], merge: true)
    }
    func addReviewToFirebase(restaurant: RestaurantDetail) {
        var newReviewList: [[String: Any]] = []
        // get each reviews put in dictionary for uploading
        for riviu in restaurant.reviews {
            let newReview = ["reviewDescription": riviu.reviewDescription, "dateCreated": riviu.dateCreated, "rating": riviu.rating, "username": riviu.username, "email": riviu.email, "image": riviu.image, "isLiked": riviu.isLiked] as [String: Any]
            newReviewList.append(newReview)
        }
        // assign new data to firestore
        Firestore.firestore().collection("restaurant").document(restaurant.place_id ?? "").updateData([
            "reviews": newReviewList
        ])
    }
    func fetchReviewFromFirebase(restaurant: RestaurantDetail, model: RestaurantModel) {
        let docRef = Firestore.firestore().collection("restaurant").document(restaurant.place_id ?? "")
        //https://stackoverflow.com/questions/55368369/how-to-get-an-array-of-objects-from-firestore-in-swift
        docRef.getDocument { document, error in
            if let error = error as NSError? {
                print("Error getting document: \(error.localizedDescription)")
            }
            else {
                if let document = document {
                    let data = document.data()
                    let reviews = data?["reviews"] as? [[String: Any]]
                    for review in reviews ?? [] {
                        //https://stackoverflow.com/questions/42186398/swift-firebase-could-not-cast-value-of-type-nsdictionarym
                        let reviewDescription: String = review["reviewDescription"] as? String ?? ""
                        let timestamp: Timestamp = review["dateCreated"] as? Timestamp ?? Timestamp()
                        let dateCreated: Date = timestamp.dateValue()
                        let rating: Int = review["rating"] as? Int ?? 1
                        let username: String = review["username"] as? String ?? ""
                        let email: String = review["email"] as? String ?? ""
                        let image: String = review["image"] as? String ?? ""
                        let isLiked: Bool = review["isLiked"] as? Bool ?? false
                        let newReview = Review(reviewDescription: reviewDescription, dateCreated: dateCreated, rating: rating, username: username, email: email, image: image, isLiked: isLiked)
                        self.reviewFetch.append(newReview)
                    }
                    // assign to the reviews on local
                    model.restaurantDetail?.reviews = self.reviewFetch
                }
            }
        }

    }
}
