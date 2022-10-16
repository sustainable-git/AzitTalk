//
//  MailView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/06/07.
//
//  https://stackoverflow.com/questions/56784722/swiftui-send-email

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    private let reportMessage: String = """
    [신고자 정보]
    신고/요청사항:
    
    [신고 대상 정보]
    메세지:
    (스크린샷 첨부 권장)
    
    AzitTalk 내부 규정에 의거하여 24시간 이내로 검토하여 안내드리겠습니다. 일부 요청은 지연될 수 있습니다.
    """
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<PresentationMode>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            self._presentation = presentation
            self._result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
                defer { self.$presentation.wrappedValue.dismiss() }
                if let error = error {
                    self.result = .failure(error)
                    return
                }
                self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation, result: self.$result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = context.coordinator
        viewController.setToRecipients(["shiung22@pos.idserve.net"])
        viewController.setSubject("AzitTalk 유저 신고")
        viewController.setMessageBody(self.reportMessage, isHTML: false)
        return viewController
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) { }
}
