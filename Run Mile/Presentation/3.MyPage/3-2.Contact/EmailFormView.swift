//
//  EmailFormView.swift
//  Run Mile
//
//  Created by 문인범 on 5/2/25.
//

import SwiftUI
import MessageUI


struct EmailFormView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        
        let body =
            """
            <html>
            <body>
            <h1>문의 내용을 작성해주세요!</h1>
            <br>
            <br>
            <p>=============<br>
            기기 : \(UIDevice.current.modelName)<br>
            OS : \(UIDevice.current.systemVersion)<br>
            앱 버전 : \(Bundle.main.appVersion)<br>
            빌드 넘버 : \(Bundle.main.buildNumber)<br>
            =============</p>
            </body>
            </html>
            """
        
        vc.setToRecipients(["dlsqja567@naver.com"])
        vc.setSubject("[Run Mile] 문의 메일")
        vc.setMessageBody(body, isHTML: true)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: EmailFormView
        
        init(parent: EmailFormView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
            switch result {
            case .sent:
                let alertData = AlertData(
                    title: "메일을 성공적으로 보냈습니다.",
                    message: nil,
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                )
                Task {
                    await NavigationCoordinator.shared.push(alertData)
                }
            case .failed:
                let alertData = AlertData(
                    title: "오류가 발생했습니다.",
                    message: error?.localizedDescription ?? "알 수 없음",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                )
                Task {
                    await NavigationCoordinator.shared.push(alertData)
                }
            default:
                break
            }
            
            parent.dismiss()
        }
    }
}
