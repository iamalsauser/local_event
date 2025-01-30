import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @AppStorage("authToken") private var authToken: String?

    @State private var isAuthenticated = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button("Login") {
                    login()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                NavigationLink(destination: EventCheckInView(), isActive: $isAuthenticated) {
                    EmptyView()
                }
            }
            .padding()
        }
    }

    func login() {
        guard let url = URL(string: "https://space-api-530b.onrender.com/api/auth/login") else { return }

        let body: [String: String] = ["email": email, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { self.errorMessage = "Network error" }
                return
            }

            if let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let token = response["token"] as? String {
                DispatchQueue.main.async {
                    self.authToken = token
                    self.isAuthenticated = true
                }
            } else {
                DispatchQueue.main.async { self.errorMessage = "Invalid credentials" }
            }
        }.resume()
    }
}
