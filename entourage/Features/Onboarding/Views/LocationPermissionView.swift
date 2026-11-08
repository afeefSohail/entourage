import SwiftUI
import CoreLocation

@Observable
final class LocationPermissionCoordinator: NSObject, CLLocationManagerDelegate {
    var status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestIfNeeded() {
        if status == .notDetermined { manager.requestWhenInUseAuthorization() }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
    }
}

struct LocationPermissionView: View {
    @Environment(OnboardingCoordinator.self) private var coordinator
    @State private var locationCoord = LocationPermissionCoordinator()
    @State private var isUpdating = false

    private var isAuthorized: Bool {
        locationCoord.status == .authorizedWhenInUse || locationCoord.status == .authorizedAlways
    }

    private var isDenied: Bool {
        locationCoord.status == .denied || locationCoord.status == .restricted
    }

    var body: some View {
        ZStack {
            Color(red: 0.984, green: 0.984, blue: 0.992).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 50)

                Image("icon_location")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 62)

                Text("Locating your Group")
                    .font(.custom("Avenir-BlackOblique", size: 22))
                    .padding(.top, 36)

                Text("Turn on Location Services\nto Continue")
                    .font(.custom("AvenirNext-Medium", size: 22))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                Text("You cannot find groups on Entourage without your\nlocation. Please enable location services to continue.")
                    .font(.custom("Avenir-Book", size: 13))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
                    .padding(.top, 16)

                Spacer()

                Button {
                    Task { await primaryAction() }
                } label: {
                    ZStack {
                        Text(isDenied ? "Go to Settings" : "Allow Location Access")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .opacity(isUpdating ? 0 : 1)
                        if isUpdating { ProgressView().tint(.white) }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("themeColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isUpdating)
                .padding(.horizontal, 24)

                Button("Maybe later") {
                    coordinator.push(.notificationPermission)
                }
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            locationCoord.requestIfNeeded()
            if isAuthorized { await updateAndProceed() }
        }
        .onChange(of: locationCoord.status) { _, newStatus in
            if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                Task { await updateAndProceed() }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            let newStatus = CLLocationManager.authorizationStatus()
            locationCoord.status = newStatus
            if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                Task { await updateAndProceed() }
            }
        }
    }

    private func primaryAction() async {
        if isDenied {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            await UIApplication.shared.open(url)
        } else if isAuthorized {
            await updateAndProceed()
        } else {
            locationCoord.requestIfNeeded()
        }
    }

    private func updateAndProceed() async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            UserRepository.shared.updateLocation { _, _ in cont.resume() }
        }
        coordinator.push(.notificationPermission)
    }
}
