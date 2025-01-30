import SwiftUI

struct EventCheckInView: View {
    @State private var searchText = ""
    @State private var participants: [Participant] = []
    @State private var scannedCode: String? = nil
    @State private var isScanning = false
    @AppStorage("authToken") private var authToken: String?

    var body: some View {
        NavigationView {
            VStack {
                // Manual Check-in
                TextField("Search by name", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Search") {
                    fetchParticipants()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                List(participants) { participant in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(participant.name).bold()
                            Text(participant.email).foregroundColor(.gray)
                        }
                        Spacer()
                        Button("Check-in") {
                            checkInParticipant(id: participant.id)
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }

                // QR Scanner Button
                Button(action: {
                    isScanning = true
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan QR Code")
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .sheet(isPresented: $isScanning) {
                    QRScannerView(scannedCode: $scannedCode, isScanning: $isScanning)
                }

                if let code = scannedCode {
                    Text("Scanned QR: \(code)")
                        .foregroundColor(.blue)
                        .padding()

                    Button("Fetch Details") {
                        fetchParticipantDetails(from: code)
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("Event Check-in")
            .onChange(of: scannedCode) { newCode in
                if let newCode = newCode {
                    fetchParticipantDetails(from: newCode)
                }
            }
        }
    }

    func fetchParticipants() {
        guard let url = URL(string: "https://space-api-530b.onrender.com/api/members") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let participants = try? JSONDecoder().decode([Participant].self, from: data) {
                DispatchQueue.main.async {
                    self.participants = participants.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                }
            }
        }.resume()
    }

    func fetchParticipantDetails(from qrCode: String) {
        guard let url = URL(string: qrCode) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let participant = try? JSONDecoder().decode(Participant.self, from: data) {
                DispatchQueue.main.async {
                    self.participants = [participant]
                }
            }
        }.resume()
    }

    func checkInParticipant(id: String) {
        guard let url = URL(string: "https://space-api-530b.onrender.com/api/visitorslog/log/\(id)") else { return }

        let body = ["purpose": "Event"]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, _, _ in
            print("Check-in successful")
        }.resume()
    }
}

struct Participant: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
}
