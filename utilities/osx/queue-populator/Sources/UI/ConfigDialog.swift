import AppKit
import AVFoundation

@MainActor
private final class ModalCloseDelegate: NSObject, NSWindowDelegate {
    private let close: () -> Void

    init(close: @escaping () -> Void) {
        self.close = close
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        close()
        return false
    }
}

@MainActor
func showConfigDialog(config: QueuePopulatorConfig) -> QueuePopulatorConfig? {
    let app = NSApplication.shared
    fputs("queue-populator: config dialog opening\n", stderr)

    let panel = NSPanel(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 612),
        styleMask: [.titled, .closable],
        backing: .buffered,
        defer: false
    )
    panel.title = "Queue Populator — Configuration"
    panel.isFloatingPanel = true
    panel.level = .floating

    let contentView = NSView(frame: panel.contentView!.bounds)
    contentView.autoresizingMask = [.width, .height]
    panel.contentView = contentView

    let fieldX: CGFloat = 120
    let fieldWidth: CGFloat = 330
    let rowHeight: CGFloat = 32
    let sectionGap: CGFloat = 12
    var y: CGFloat = 577
    let audioDevices = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.microphone, .external],
        mediaType: .audio,
        position: .unspecified
    ).devices

    func makeLabel(_ text: String) -> NSTextField {
        let lbl = NSTextField(labelWithString: text)
        lbl.font = NSFont.systemFont(ofSize: 13)
        return lbl
    }

    func makeSectionHeader(_ text: String) {
        y -= sectionGap
        let lbl = NSTextField(labelWithString: text)
        lbl.font = NSFont.boldSystemFont(ofSize: 12)
        lbl.textColor = .secondaryLabelColor
        lbl.frame = NSRect(x: 12, y: y - 18, width: 440, height: 18)
        contentView.addSubview(lbl)
        y -= 22
    }

    func addRow(label: String, value: String, placeholder: String = "") -> NSTextField {
        let lbl = makeLabel(label)
        lbl.frame = NSRect(x: 12, y: y - rowHeight + 6, width: 100, height: 20)
        contentView.addSubview(lbl)

        let field = NSTextField(frame: NSRect(x: fieldX, y: y - rowHeight + 4, width: fieldWidth, height: 24))
        field.stringValue = value
        field.placeholderString = placeholder
        contentView.addSubview(field)
        y -= rowHeight
        return field
    }

    // --- Phrases ---
    makeSectionHeader("VOICE PHRASES")
    let wakeField = addRow(label: "Wake:", value: config.phrases.wake, placeholder: "hey robot")
    let endField = addRow(label: "End:", value: config.phrases.end, placeholder: "full stop")
    let approveMemoField = addRow(label: "Approve memo:", value: config.phrases.approveMemo, placeholder: "approve memo")
    let cancelField = addRow(label: "Cancel:", value: config.phrases.cancel, placeholder: "cancel that")
    let approveField = addRow(label: "Approve:", value: config.phrases.approve, placeholder: "looks good")
    let reviseField = addRow(label: "Revise:", value: config.phrases.revise, placeholder: "revise that")

    // --- Queue ---
    makeSectionHeader("QUEUE")
    let queuePathField = addRow(label: "Base path:", value: config.queueBasePath, placeholder: "~/personal-development/queue")

    // --- Recognition ---
    makeSectionHeader("RECOGNITION")

    let deviceLabel = makeLabel("Microphone:")
    deviceLabel.frame = NSRect(x: 12, y: y - rowHeight + 6, width: 100, height: 20)
    contentView.addSubview(deviceLabel)

    let devicePopup = NSPopUpButton(frame: NSRect(x: fieldX, y: y - rowHeight + 2, width: fieldWidth, height: 26), pullsDown: false)
    devicePopup.addItem(withTitle: "System Default")
    for device in audioDevices {
        devicePopup.addItem(withTitle: device.localizedName)
        devicePopup.lastItem?.representedObject = device.uniqueID
    }
    if let selectedDeviceId = config.recognition.inputDeviceId,
       let item = devicePopup.itemArray.first(where: { ($0.representedObject as? String) == selectedDeviceId }) {
        devicePopup.select(item)
    }
    contentView.addSubview(devicePopup)
    y -= rowHeight

    // --- LLM ---
    makeSectionHeader("LLM INFERENCE")

    let provLabel = makeLabel("Provider:")
    provLabel.frame = NSRect(x: 12, y: y - rowHeight + 6, width: 100, height: 20)
    contentView.addSubview(provLabel)

    let providerPopup = NSPopUpButton(frame: NSRect(x: fieldX, y: y - rowHeight + 2, width: fieldWidth, height: 26), pullsDown: false)
    providerPopup.addItems(withTitles: LlmConfig.providers)
    providerPopup.selectItem(withTitle: config.llm.provider)
    contentView.addSubview(providerPopup)
    y -= rowHeight

    let apiKeyField = addRow(label: "API Key:", value: config.llm.apiKey ?? "", placeholder: "env: ANTHROPIC_API_KEY")
    let baseUrlField = addRow(label: "Base URL:", value: config.llm.baseUrl ?? "", placeholder: "https://api.example.com/v1")

    let modelLabel = makeLabel("Model:")
    modelLabel.frame = NSRect(x: 12, y: y - rowHeight + 6, width: 100, height: 20)
    contentView.addSubview(modelLabel)

    let modelPopup = NSPopUpButton(frame: NSRect(x: fieldX, y: y - rowHeight + 2, width: fieldWidth - 110, height: 26), pullsDown: false)
    modelPopup.addItem(withTitle: config.llm.model ?? LlmConfig.defaultModels[config.llm.provider] ?? "—")
    contentView.addSubview(modelPopup)

    let fetchButton = NSButton(frame: NSRect(x: fieldX + fieldWidth - 104, y: y - rowHeight + 2, width: 104, height: 26))
    fetchButton.title = "Fetch Models"
    fetchButton.bezelStyle = .rounded
    contentView.addSubview(fetchButton)
    y -= rowHeight

    let testButton = NSButton(frame: NSRect(x: fieldX, y: y - rowHeight + 2, width: 120, height: 26))
    testButton.title = "Test Inference"
    testButton.bezelStyle = .rounded
    contentView.addSubview(testButton)
    y -= rowHeight

    let statusLabel = NSTextField(labelWithString: "")
    statusLabel.frame = NSRect(x: fieldX, y: y - 20, width: fieldWidth, height: 18)
    statusLabel.font = NSFont.systemFont(ofSize: 11)
    statusLabel.textColor = .secondaryLabelColor
    contentView.addSubview(statusLabel)

    func currentLlmConfig() -> LlmConfig {
        var llm = LlmConfig()
        llm.provider = providerPopup.titleOfSelectedItem ?? "anthropic"
        let apiKey = apiKeyField.stringValue.trimmingCharacters(in: .whitespaces)
        llm.apiKey = apiKey.isEmpty ? nil : apiKey
        let baseUrl = baseUrlField.stringValue.trimmingCharacters(in: .whitespaces)
        llm.baseUrl = baseUrl.isEmpty ? nil : baseUrl
        llm.model = modelPopup.titleOfSelectedItem
        return llm
    }

    // --- Fetch models ---
    let fetchTarget = BlockTarget {
        let prov = providerPopup.titleOfSelectedItem ?? "anthropic"
        let key = apiKeyField.stringValue.trimmingCharacters(in: .whitespaces)
        let url = baseUrlField.stringValue.trimmingCharacters(in: .whitespaces)

        let effectiveKey: String? = key.isEmpty ? {
            if let envVar = LlmConfig.envVarKeys[prov] {
                return ProcessInfo.processInfo.environment[envVar]
            }
            return nil
        }() : key

        statusLabel.stringValue = "Fetching models..."
        fetchButton.isEnabled = false

        Task {
            let models = await fetchModels(
                provider: prov,
                apiKey: effectiveKey,
                baseUrl: url.isEmpty ? LlmConfig.defaultBaseUrls[prov] : url
            )
            await MainActor.run {
                fetchButton.isEnabled = true
                modelPopup.removeAllItems()
                if models.isEmpty {
                    modelPopup.addItem(withTitle: LlmConfig.defaultModels[prov] ?? "—")
                    statusLabel.stringValue = "Could not fetch — using default"
                } else {
                    modelPopup.addItems(withTitles: models)
                    statusLabel.stringValue = "\(models.count) models loaded"
                }
            }
        }
    }
    fetchButton.target = fetchTarget
    fetchButton.action = #selector(BlockTarget.invoke)

    // --- Test inference ---
    let testTarget = BlockTarget {
        let llmConfig = currentLlmConfig()
        let client = LlmClient(config: llmConfig)

        statusLabel.stringValue = "Testing inference..."
        testButton.isEnabled = false

        Task {
            do {
                let response = try await client.classify(
                    system: """
                    Return only valid JSON in this exact shape:
                    {"entries":[{"file":"tasks.jsonl","type":"task","text":"test inference"}],"reasoning":"ok"}
                    Use tasks.jsonl as the file.
                    """,
                    user: "Classify this memo: test inference for queue populator"
                )
                await MainActor.run {
                    testButton.isEnabled = true
                    statusLabel.stringValue = "Inference OK — \(response.entries.count) test entry"
                }
            } catch {
                await MainActor.run {
                    testButton.isEnabled = true
                    statusLabel.stringValue = "Inference failed — \(error)"
                }
            }
        }
    }
    testButton.target = testTarget
    testButton.action = #selector(BlockTarget.invoke)

    // --- Buttons ---
    let saveButton = NSButton(frame: NSRect(x: 480 - 130, y: 12, width: 110, height: 32))
    saveButton.title = "Save"
    saveButton.bezelStyle = .rounded
    saveButton.keyEquivalent = "\r"
    contentView.addSubview(saveButton)

    let cancelButton = NSButton(frame: NSRect(x: 480 - 240, y: 12, width: 100, height: 32))
    cancelButton.title = "Cancel"
    cancelButton.bezelStyle = .rounded
    cancelButton.keyEquivalent = "\u{1b}"
    contentView.addSubview(cancelButton)

    let saveTarget = BlockTarget {
        panel.orderOut(nil)
        app.stopModal(withCode: .OK)
    }
    let cancelTarget = BlockTarget {
        panel.orderOut(nil)
        app.stopModal(withCode: .cancel)
    }
    let closeDelegate = ModalCloseDelegate {
        panel.orderOut(nil)
        app.stopModal(withCode: .cancel)
    }
    panel.delegate = closeDelegate
    saveButton.target = saveTarget
    saveButton.action = #selector(BlockTarget.invoke)
    cancelButton.target = cancelTarget
    cancelButton.action = #selector(BlockTarget.invoke)

    panel.center()
    showInteractiveWindow(panel)
    let response = app.runModal(for: panel)
    panel.orderOut(nil)
    panel.delegate = nil
    panel.close()
    fputs("queue-populator: config dialog closed response=\(response.rawValue)\n", stderr)

    _ = (fetchTarget, testTarget, saveTarget, cancelTarget, closeDelegate)

    guard response == .OK else { return nil }

    var updated = config
    updated.phrases.wake = wakeField.stringValue.lowercased().trimmingCharacters(in: .whitespaces)
    updated.phrases.end = endField.stringValue.lowercased().trimmingCharacters(in: .whitespaces)
    updated.phrases.approveMemo = approveMemoField.stringValue.lowercased().trimmingCharacters(in: .whitespaces)
    updated.phrases.cancel = cancelField.stringValue.lowercased().trimmingCharacters(in: .whitespaces)
    updated.phrases.approve = approveField.stringValue.lowercased().trimmingCharacters(in: .whitespaces)
    updated.phrases.revise = reviseField.stringValue.lowercased().trimmingCharacters(in: .whitespaces)
    updated.queueBasePath = queuePathField.stringValue.trimmingCharacters(in: .whitespaces)
    updated.recognition.inputDeviceId = devicePopup.selectedItem?.representedObject as? String
    updated.llm = currentLlmConfig()

    return updated
}
