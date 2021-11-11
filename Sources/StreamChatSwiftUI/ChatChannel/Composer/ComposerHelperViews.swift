//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View used to indicate that an asset is a video.
struct VideoIndicatorView: View {
    var body: some View {
        BottomLeftView {
            Image(systemName: "video.fill")
                .renderingMode(.template)
                .font(.system(size: 17, weight: .bold))
                .applyDefaultIconOverlayStyle()
        }
    }
}

/// View displaying the duration of the video.
struct VideoDurationIndicatorView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var duration: String
    
    var body: some View {
        BottomRightView {
            Text(duration)
                .foregroundColor(Color(colors.staticColorText))
                .font(fonts.footnoteBold)
                .padding(.all, 4)
        }
    }
}

/// Container that displays attachment types.
struct AttachmentTypeContainer<Content: View>: View {
    @Injected(\.colors) var colors
    
    var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            Color(colors.background)
                .frame(height: 20)
            
            content()
                .background(Color(colors.background))
        }
        .background(Color(colors.background1))
        .cornerRadius(16)
    }
}

/// View shown after the native file picker is closed.
struct FilePickerDisplayView: View {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    @Binding var filePickerShown: Bool
    @Binding var addedFileURLs: [URL]
    
    var body: some View {
        AttachmentTypeContainer {
            ZStack {
                Button {
                    filePickerShown = true
                } label: {
                    Text("Add more files")
                        .font(fonts.bodyBold)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(Color(colors.highlightedAccentBackground))
            .sheet(isPresented: $filePickerShown) {
                FilePickerView(fileURLs: $addedFileURLs)
            }
        }
    }
}

/// View displayed when the camera picker is shown.
struct CameraPickerDisplayView: View {
    @Binding var selectedPickerState: AttachmentPickerState
    @Binding var cameraPickerShown: Bool
    
    var cameraImageAdded: (AddedAsset) -> Void
    
    var body: some View {
        Spacer()
            .sheet(isPresented: $cameraPickerShown, onDismiss: {
                selectedPickerState = .photos
            }) {
                ImagePickerView(sourceType: .camera) { addedImage in
                    cameraImageAdded(addedImage)
                }
            }
    }
}

/// View displayed when there's no access permission to the photo library.
struct AssetsAccessPermissionView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("You have not granted access to the photo library.")
                .font(fonts.body)
            Button {
                openAppPrivacySettings()
            } label: {
                Text("Change in Settings")
                    .font(fonts.bodyBold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(colors.highlightedAccentBackground))
            }
            Spacer()
        }
        .padding(.all, 8)
    }
    
    func openAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
