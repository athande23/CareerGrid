import SwiftUI

struct ApplicationProgressView: View {
    
    let currentStage: ApplicationStage
    
    private let stages: [ApplicationStage] = [
        .applied,
        .onlineAssessment,
        .interview,
        .finalInterview,
        .decision,
        .offer
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(
                Array(stages.enumerated()),
                id: \.element
            ) { index, stage in
                
                stageIndicator(
                    stage: stage,
                    isCompleted: index <= currentStageIndex
                )
                
                if index < stages.count - 1 {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(
                            index < currentStageIndex
                            ? Color.accentColor
                            : Color.secondary.opacity(0.3)
                        )
                }
            }
        }
    }
    
    private var currentStageIndex: Int {
        stages.firstIndex(of: currentStage) ?? 0
    }
    
    private func stageIndicator(
        stage: ApplicationStage,
        isCompleted: Bool
    ) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(
                    isCompleted
                    ? Color.accentColor
                    : Color.secondary.opacity(0.3)
                )
                .frame(width: 12, height: 12)
            
            Text(shortName(for: stage))
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 35)
    }
    
    private func shortName(
        for stage: ApplicationStage
    ) -> String {
        switch stage {
        case .applied:
            return "Applied"
        case .onlineAssessment:
            return "OA"
        case .interview:
            return "Interview"
        case .finalInterview:
            return "Final"
        case .decision:
            return "Decision"
        case .offer:
            return "Offer"
        case .rejected:
            return "Rejected"
        }
    }
}

