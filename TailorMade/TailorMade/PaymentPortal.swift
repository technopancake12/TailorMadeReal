import SwiftUI

struct PaymentPortal: View {
    @State private var cardNumber = ""
    @State private var cardHolderName = ""
    @State private var expirationDate = ""
    @State private var cvv = ""
    @State private var isDropdownOpen = false
    @State private var selectedPaymentMethod: PaymentMethod? // Default selection
    @State private var paymentStatus: PaymentStatus? // Track payment status
    
    enum PaymentMethod: String, CaseIterable, Identifiable {
        case mastercard = "Mastercard"
        case visa = "Visa"

        var id: String { self.rawValue }
        
        var logo: Image {
            switch self {
            case .mastercard:
                return Image("mastercard_logo")
            case .visa:
                return Image("visa_logo")
            }
        }
    }

    enum PaymentStatus {
        case success, failure
    }

    var body: some View {
        VStack {
            Text("Payment Portal")
                .font(.title)
                .padding()

            Button(action: {
                withAnimation {
                    isDropdownOpen.toggle()
                }
            }) {
                HStack {
                    selectedPaymentMethod?.logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30) // Adjust size as needed
                        .padding(.trailing, 8)
                    Text(selectedPaymentMethod?.rawValue ?? "Select Payment Method")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
            }
            .foregroundColor(.primary)
            .padding()

            if isDropdownOpen {
                VStack {
                    ForEach(PaymentMethod.allCases) { method in
                        Button(action: {
                            withAnimation {
                                selectedPaymentMethod = method
                                isDropdownOpen = false
                            }
                        }) {
                            HStack {
                                method.logo
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30) // Adjust size as needed
                                    .padding(.trailing, 8)
                                Text(method.rawValue)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedPaymentMethod == method ? Color.blue.opacity(0.5) : Color.clear)
                            .cornerRadius(10)
                            .foregroundColor(selectedPaymentMethod == method ? .white : .primary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                .padding()
            }

            TextField("Card Number", text: $cardNumber)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Cardholder Name", text: $cardHolderName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            HStack {
                TextField("Expiration Date (MM/YY)", text: $expirationDate)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("CVV", text: $cvv)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Button("Submit Payment") {
                authorizePayment()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .padding()

            if let status = paymentStatus {
                Text(status == .success ? "Payment Successful!" : "Payment Failed!")
                    .foregroundColor(status == .success ? .green : .red)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    private func authorizePayment() {
        // This is a simulation of payment authorization using the selected payment method
        if cardNumber.isValidCardNumber() && expirationDate.isValidExpirationDate() && cvv.isValidCVV() {
            // Perform additional checks or validation logic here as needed
            if let selectedMethod = selectedPaymentMethod {
                print("Selected Payment Method: \(selectedMethod.rawValue)")
                paymentStatus = .success
            } else {
                paymentStatus = .failure
            }
        } else {
            paymentStatus = .failure
        }
    }
}

extension String {
    // Add custom validation methods for card number, expiration date, and CVV
    func isValidCardNumber() -> Bool {
        // Validate card number format (e.g., length, characters)
        return true // Replace with actual validation logic
    }
    
    func isValidExpirationDate() -> Bool {
        // Validate expiration date format (e.g., MM/YY format)
        return true // Replace with actual validation logic
    }
    
    func isValidCVV() -> Bool {
        // Validate CVV format (e.g., length, characters)
        return true // Replace with actual validation logic
    }
}

struct PaymentPortal_Previews: PreviewProvider {
    static var previews: some View {
        PaymentPortal()
    }
}
