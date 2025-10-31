//
//  ErrorBanner.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//
import SwiftUI

// MARK: - Error Banner Component
struct ErrorBanner: View {
    let error: String
    let errorType: ErrorType
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    init(error: String, errorType: ErrorType = .general, onRetry: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.error = error
        self.errorType = errorType
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: errorType.iconName)
                    .foregroundColor(errorType.iconColor)
                    .font(.title3)
                    .accessibilityHidden(true)
                
                // Message
                VStack(alignment: .leading, spacing: 2) {
                    Text(errorType.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(errorType.textColor)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .accessibilityLabel(String(localized: "error_details_message \(error)"))
                }
                .accessibilityElement(children: .combine)
                
                Spacer()
                
                // Actions
                HStack(spacing: 8) {
                    if let onDismiss = onDismiss {
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.secondary)
                                .padding(6)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel(String(localized:"dismiss_error_label"))
                    }
                    
                    if let onRetry = onRetry {
                        Button(String(localized:"retry_button")) {
                            onRetry()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .accessibilityLabel(String(localized:"retry_operation_label"))
                    }
                }
            }
            .padding()
            .background(errorType.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorType.borderColor, lineWidth: 1)
            )
        }
        .shadow(color: errorType.shadowColor, radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(errorType.title). \(error)")
    }
}

// MARK: - Error Type
extension ErrorBanner {
    enum ErrorType {
        case general
        case network
        case server
        case warning
        case info
        
        var iconName: String {
            switch self {
            case .general: return "exclamationmark.triangle.fill"
            case .network: return "wifi.exclamationmark"
            case .server: return "server.rack"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var iconColor: Color {
            switch self {
            case .general: return .orange
            case .network: return .blue
            case .server: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
        
        var title: String {
            switch self {
            case .general: return String(localized: "general_banner_error", comment: "General error title")
            case .network: return String(localized: "network_banner_error", comment: "Network error title")
            case .server: return String(localized: "server_banner_error", comment: "Server error title")
            case .warning: return String(localized: "warning_banner_error", comment: "Warning title")
            case .info: return String(localized: "information_banner_error", comment: "Info title")
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .general: return .orange.opacity(0.1)
            case .network: return .blue.opacity(0.1)
            case .server: return .red.opacity(0.1)
            case .warning: return .orange.opacity(0.1)
            case .info: return .blue.opacity(0.1)
            }
        }
        
        var borderColor: Color {
            switch self {
            case .general: return .orange.opacity(0.3)
            case .network: return .blue.opacity(0.3)
            case .server: return .red.opacity(0.3)
            case .warning: return .orange.opacity(0.3)
            case .info: return .blue.opacity(0.3)
            }
        }
        
        var shadowColor: Color {
            switch self {
            case .general: return .orange.opacity(0.1)
            case .network: return .blue.opacity(0.1)
            case .server: return .red.opacity(0.1)
            case .warning: return .orange.opacity(0.1)
            case .info: return .blue.opacity(0.1)
            }
        }
        
        var textColor: Color {
            switch self {
            case .general: return .primary
            case .network: return .primary
            case .server: return .primary
            case .warning: return .primary
            case .info: return .primary
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        ErrorBanner(
            error: "Unable to load characters. Please check your connection.",
            errorType: .network,
            onRetry: { print("Retry tapped") }
        )
        
        ErrorBanner(
            error: "Server is currently unavailable. Please try again later.",
            errorType: .server,
            onRetry: { print("Retry tapped") }
        )
        
        ErrorBanner(
            error: "An unexpected error occurred.",
            errorType: .general,
            onRetry: { print("Retry tapped") }
        )
        
        ErrorBanner(
            error: "This is a warning message.",
            errorType: .warning
        )
        
        ErrorBanner(
            error: "This is an informational message.",
            errorType: .info
        )
    }
    .padding()
}
