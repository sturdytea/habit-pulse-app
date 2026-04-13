import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var iconBreath: CGFloat = 1
    @State private var titleOffset: CGFloat = 24
    @State private var titleOpacity: Double = 0
    @State private var glowPulse: CGFloat = 1
    @State private var loadProgress: CGFloat = 0
    @State private var footerOpacity: Double = 0

    private let splashDuration: TimeInterval = 2.85

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    AppTheme.teal.opacity(0.35),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 220
            )
            .scaleEffect(glowPulse)
            .opacity(0.9)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(
                                AppTheme.teal.opacity(0.15),
                                lineWidth: 3
                            )
                            .frame(width: 120, height: 120)

                        SplashSpinningArc()
                            .frame(width: 120, height: 120)

                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 64, weight: .medium))
                            .foregroundStyle(AppTheme.accentGradient)
                            .scaleEffect(iconScale * iconBreath)
                            .opacity(iconOpacity)
                    }
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)

                    VStack(spacing: 6) {
                        Text("HabitPulse")
                            .font(.system(.title, design: .rounded).weight(.bold))
                            .foregroundColor(.white)
                        Text("Ритм полезных привычек")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
                }

                Spacer(minLength: 0)

                VStack(spacing: 14) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.12))
                            Capsule()
                                .fill(AppTheme.accentGradient)
                                .frame(width: max(8, geo.size.width * loadProgress))
                        }
                    }
                    .frame(height: 5)
                    .accessibilityLabel("Индикатор загрузки")

                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.95)
                        SplashLoadingLabel()
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 36)
                .opacity(footerOpacity)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                iconBreath = 1.06
            }
            withAnimation(.spring(response: 0.85, dampingFraction: 0.72)) {
                ringScale = 1
                ringOpacity = 1
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.12)) {
                iconScale = 1
                iconOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.55).delay(0.35)) {
                titleOffset = 0
                titleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.45).delay(0.5)) {
                footerOpacity = 1
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                glowPulse = 1.08
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                withAnimation(.easeInOut(duration: splashDuration - 0.65)) {
                    loadProgress = 1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
                withAnimation(.easeInOut(duration: 0.45)) {
                    onFinished()
                }
            }
        }
    }
}

/// Плавное бесконечное вращение дуги без сброса кадра (iOS 15+).
private struct SplashSpinningArc: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let degrees = (t.truncatingRemainder(dividingBy: 1.35) / 1.35) * 360
            Circle()
                .trim(from: 0, to: 0.28)
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.teal, AppTheme.emerald],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(degrees))
        }
    }
}

private struct SplashLoadingLabel: View {
    private let labels = ["Загрузка", "Загрузка.", "Загрузка..", "Загрузка..."]

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 0.45)) { context in
            let i = Int(context.date.timeIntervalSinceReferenceDate / 0.45) % labels.count
            Text(labels[i])
                .font(.footnote.weight(.medium))
                .foregroundColor(.white.opacity(0.85))
                .animation(.easeInOut(duration: 0.2), value: i)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(onFinished: {})
    }
}
