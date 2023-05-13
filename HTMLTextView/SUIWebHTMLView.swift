//
//  SUIWebHTMLView.swift
//  Fairylight
//
//  Created by Alan Zúñiga on 2023/4/18.
//

import SwiftUI
import WebKit

struct SUIWebHTMLView: UIViewRepresentable {
	@Binding private var dynamicHeight: CGFloat
    @Binding private var isExpanded: Bool

	var view: WKWebView!

	private var html: String

    private var textColor: Color
    private var textSize: Double
    private var textLineLimit: Int

	class Coordinator: NSObject, WKNavigationDelegate {
		var parent: SUIWebHTMLView

		init(_ parent: SUIWebHTMLView) {
			self.parent = parent
		}

		public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let cleanedCSS: String = parent.configureCSS(
                textColor: parent.textColor,
                textSize: Int(parent.textSize),
                textLineLimit: parent.textLineLimit
            )
                .minify()
            var styleInjectorJS = SUIWebHTMLView.readFile(SUIWebHTMLView.Constants.styleInjector)

            styleInjectorJS = String(format: styleInjectorJS, "\(cleanedCSS)")

            webView.evaluateJavaScript(styleInjectorJS)

			webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, _) in
				DispatchQueue.main.async {
					self.parent.dynamicHeight = height as? CGFloat ?? 0.0
				}
			})
		}
	}

    struct Constants {
		typealias SUIFile = (name: String, type: String)

        static let collapsedStyle: SUIFile = ("collapsedStyle", "css")
        static let expandedStyle: SUIFile = ("expandedStyle", "css")
		static let styleInjector: SUIFile = ("styleInjector", "js")
	}

	init(
		html: String,
		textColor: Color,
		textSize: Double,
		textLineLimit: Int,
        isExpanded: Binding<Bool>,
		dynamicHeight: Binding<CGFloat>
	) {
		// Assign height and html to self
		self._dynamicHeight = dynamicHeight
        self._isExpanded = isExpanded

        self.html = html

        self.textColor = textColor
        self.textSize = textSize
        self.textLineLimit = textLineLimit

		// Configure and get minified CSS
		let cleanedCSS: String = configureCSS(
			textColor: textColor,
			textSize: Int(textSize),
			textLineLimit: textLineLimit
		)
		.minify()

		// Get minified style injector (JS)
        var styleInjectorJS = SUIWebHTMLView.readFile(Self.Constants.styleInjector)

		// Format style injector (JS) using cleaned CSS
		styleInjectorJS = String(format: styleInjectorJS, "\(cleanedCSS)")

		// Create style injector (script)
		let styleInjectorScript = WKUserScript(
			source: styleInjectorJS,
			injectionTime: .atDocumentEnd,
			forMainFrameOnly: true
		)

		// Create user controller for WebView and inject scripts
		let userContentController = WKUserContentController()
//		userContentController.addUserScript(styleInjectorScript)
		userContentController.add(HTMLScriptDelegate(), name: "SUIWebHTMLListener")

		// Create configuration for WebView and inject user controller
		let configuration = WKWebViewConfiguration()
		configuration.userContentController = userContentController

		// Create and assign WebView to self
		self.view = WKWebView(frame: .zero, configuration: configuration)
	}

	// Make Coordinator (WKWebNavigationDelegate)
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	// Make UI View
	func makeUIView(context: Context) -> WKWebView {
		view.scrollView.bounces = false
		view.navigationDelegate = context.coordinator

		return view
	}

	// Update UI View
	func updateUIView(_ uiView: WKWebView, context: Context) {
        view.reload()
	}
}

extension SUIWebHTMLView {
	private func configureCSS(
		textColor: Color,
		textSize: Int,
		textLineLimit: Int
	) -> String {
        var css = SUIWebHTMLView.readFile(isExpanded ? Constants.expandedStyle : Constants.collapsedStyle)

		css = css.replacingOccurrences(of: "%textSize@", with: "\(textSize)")
		css = css.replacingOccurrences(of: "%textColor@", with: textColor.toHex() ?? "#595959")
		css = css.replacingOccurrences(of: "%textLineLimit@", with: "\(textLineLimit)")

		return css
	}

	static func readFile(_ file: Constants.SUIFile) -> String {
		guard let path = Bundle.CCLStyles.path(forResource: file.name, ofType: file.type) else {
			return ""
		}

		do {
			return try String(contentsOfFile: path, encoding: .utf8)
		} catch {
			return ""
		}
	}
}

private extension String {
	func minify() -> String {
		self.components(separatedBy: .newlines).joined()
	}
}

// MARK: Previews
//
struct SUIHTMLView_Previews: PreviewProvider {
	static var previews: some View {
        ExpandableView()
	}
}

public struct ExpandableView: View {
    @State var isExpanded: Bool = false

    public init() {}

    public var body: some View {
        VStack {
            HTMLTestView(isExpanded: $isExpanded)
            SUIExpandableLinkView(isExpanded: $isExpanded)
        }
    }
}

public struct HTMLTestView: View {
	// MARK: State
	@State var dynamicHeight: CGFloat = .zero

	// MARK: Properties
	@ScaledMetric private var textSize: Double

	private var textColor: Color
	private var textLineLimit: Int
    @Binding private var isExpanded: Bool

	public init(
		textColor: Color = .green,
		textSize: Int = 12,
		textLineLimit: Int = 4,
        isExpanded: Binding<Bool>
	) {
		self.textColor = textColor
		self._textSize = ScaledMetric(wrappedValue: Double(textSize), relativeTo: .footnote)
		self.textLineLimit = textLineLimit
        self._isExpanded = isExpanded
	}

    public var body: some View {
		SUIWebHTMLView(
			html: readFile(),
			textColor: textColor,
			textSize: textSize,
			textLineLimit: textLineLimit,
            isExpanded: $isExpanded,
            dynamicHeight: $dynamicHeight
		)
		.frame(height: dynamicHeight)
	}

	private func readFile() -> String {
		guard let path = Bundle.CCLStyles.path(forResource: "test", ofType: "html") else {
			return "Failed to find path"
		}

		do {
			return try String(contentsOfFile: path, encoding: .utf8)
		} catch {
			return "Unkown Error"
		}
	}
}

class HTMLScriptDelegate: NSObject, WKScriptMessageHandler {
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		print("aqui", message.body)
	}
}

extension Color {
	func toHex() -> String? {
		let legacyColor: UIColor = UIColor(self)

		guard let components = legacyColor.cgColor.components,
				  components.count >= 3
		else { return nil }

		let r: Float = Float(components[0])
		let g: Float = Float(components[1])
		let b: Float = Float(components[2])
		var a: Float = Float(1.0)

		if components.count >= 4 {
			a = Float(components[3])
		}

		if a != Float(1.0) {
			return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
		} else {
			return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
		}
	}
}
