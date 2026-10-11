
import UIKit
import SwiftUI
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        loadSharedContent { [weak self] title, url in
            DispatchQueue.main.async {
                self?.showShareView(title: title, url: url)
            }
        }
    }

    private func loadSharedContent(
        completion: @escaping (String, URL?) -> Void
    ) {
        let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
        let providers = items.flatMap { $0.attachments ?? [] }
        let suggestedTitle = items.compactMap { $0.attributedTitle?.string }.first

        loadProvider(
            at: 0,
            providers: providers,
            suggestedTitle: suggestedTitle,
            completion: completion
        )
    }

    private func loadProvider(
        at index: Int,
        providers: [NSItemProvider],
        suggestedTitle: String?,
        completion: @escaping (String, URL?) -> Void
    ) {
        guard index < providers.count else {
            completion(suggestedTitle ?? "Shared job", nil)
            return
        }

        let provider = providers[index]

        if provider.canLoadObject(ofClass: NSURL.self) {
            provider.loadObject(ofClass: NSURL.self) { [weak self] object, _ in
                if let sharedURL = object as? NSURL {
                    let url = sharedURL as URL
                    completion(suggestedTitle ?? url.absoluteString, url)
                } else {
                    self?.loadProvider(
                        at: index + 1,
                        providers: providers,
                        suggestedTitle: suggestedTitle,
                        completion: completion
                    )
                }
            }
        } else if provider.canLoadObject(ofClass: NSString.self) {
            provider.loadObject(ofClass: NSString.self) { [weak self] object, _ in
                guard let sharedText = object as? String,
                      !sharedText.isEmpty else {
                    self?.loadProvider(
                        at: index + 1,
                        providers: providers,
                        suggestedTitle: suggestedTitle,
                        completion: completion
                    )
                    return
                }

                let extractedURL = self?.extractURL(from: sharedText)
                completion(suggestedTitle ?? sharedText, extractedURL)
            }
        } else {
            loadProvider(
                at: index + 1,
                providers: providers,
                suggestedTitle: suggestedTitle,
                completion: completion
            )
        }
    }

    private func extractURL(from text: String) -> URL? {
        guard let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)

        return detector.matches(
            in: text,
            options: [],
            range: range
        )
        .compactMap(\.url)
        .first { url in
            guard let scheme = url.scheme?.lowercased() else {
                return false
            }
            return scheme == "https" || scheme == "http"
        }
    }

    private func showShareView(title: String, url: URL?) {
        let viewModel = ShareExtensionViewModel(
            title: title,
            url: url
        )

        let shareView = ShareExtensionView(
            viewModel: viewModel
        ) { [weak self] in
            self?.extensionContext?.completeRequest(
                returningItems: nil,
                completionHandler: nil
            )
        }

        let hostingController = UIHostingController(rootView: shareView)

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}
