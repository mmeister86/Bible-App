# AGENTS

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: `npx openskills read <skill-name>` (run in your shell)
  - For multiple: `npx openskills read skill-one,skill-two`
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>axiom-accessibility-diag</name>
<description>Use when fixing VoiceOver issues, Dynamic Type violations, color contrast failures, touch target problems, keyboard navigation gaps, or Reduce Motion support - comprehensive accessibility diagnostics with WCAG compliance, Accessibility Inspector workflows, and App Store Review preparation for iOS/macOS</description>
<location>project</location>
</skill>

<skill>
<name>axiom-app-composition</name>
<description>Use when structuring app entry points, managing authentication flows, switching root views, handling scene lifecycle, or asking 'how do I structure my @main', 'where does auth state live', 'how do I prevent screen flicker on launch', 'when should I modularize' - app-level composition patterns for iOS 26+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-app-discoverability</name>
<description>Use when making app surface in Spotlight search, Siri suggestions, or system experiences - covers the 6-step strategy combining App Intents, App Shortcuts, Core Spotlight, and NSUserActivity to feed the system metadata for iOS 16+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-app-intents-ref</name>
<description>Use when integrating App Intents for Siri, Apple Intelligence, Shortcuts, Spotlight, or system experiences - covers AppIntent, AppEntity, parameter handling, entity queries, background execution, authentication, and debugging common integration issues for iOS 16+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-app-shortcuts-ref</name>
<description>Use when implementing App Shortcuts for instant Siri/Spotlight availability, configuring AppShortcutsProvider, adding suggested phrases, or debugging shortcuts not appearing - covers complete App Shortcuts API for iOS 16+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-app-store-connect-ref</name>
<description>Reference for App Store Connect crash analysis, TestFlight feedback, metrics dashboards, and data export workflows</description>
<location>project</location>
</skill>

<skill>
<name>axiom-apple-docs</name>
<description>Use when ANY question involves Apple framework APIs, Swift compiler errors, or Xcode-bundled documentation. Covers Liquid Glass, Swift 6.2 concurrency, Foundation Models, SwiftData, StoreKit, 32 Swift compiler diagnostics.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-apple-docs-research</name>
<description>Use when researching Apple frameworks, APIs, or WWDC sessions - provides techniques for retrieving full transcripts, code samples, and documentation using Chrome browser and sosumi.ai</description>
<location>project</location>
</skill>

<skill>
<name>axiom-assume-isolated</name>
<description>Use when needing synchronous actor access in tests, legacy delegate callbacks, or performance-critical code. Covers MainActor.assumeIsolated, @preconcurrency protocol conformances, crash behavior, Task vs assumeIsolated.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-auto-layout-debugging</name>
<description>Use when encountering "Unable to simultaneously satisfy constraints" errors, constraint conflicts, ambiguous layout warnings, or views positioned incorrectly - systematic debugging workflow for Auto Layout issues in iOS</description>
<location>project</location>
</skill>

<skill>
<name>axiom-avfoundation-ref</name>
<description>Reference — AVFoundation audio APIs, AVAudioSession categories/modes, AVAudioEngine pipelines, bit-perfect DAC output, iOS 26+ spatial audio capture, ASAF/APAC, Audio Mix with Cinematic framework</description>
<location>project</location>
</skill>

<skill>
<name>axiom-axe-ref</name>
<description>Use when automating iOS Simulator UI interactions beyond simctl capabilities. Reference for AXe CLI covering accessibility-based tapping, gestures, text input, screenshots, video recording, and UI tree inspection.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-background-processing</name>
<description>Use when implementing BGTaskScheduler, debugging background tasks that never run, understanding why tasks terminate early, or testing background execution - systematic task lifecycle management with proper registration, expiration handling, and Swift 6 cancellation patterns</description>
<location>project</location>
</skill>

<skill>
<name>axiom-background-processing-diag</name>
<description>Symptom-based background task troubleshooting - decision trees for 'task never runs', 'task terminates early', 'works in dev not prod', 'handler not called', with time-cost analysis for each diagnosis path</description>
<location>project</location>
</skill>

<skill>
<name>axiom-background-processing-ref</name>
<description>Complete background task API reference - BGTaskScheduler, BGAppRefreshTask, BGProcessingTask, BGContinuedProcessingTask (iOS 26), beginBackgroundTask, background URLSession, with all WWDC code examples</description>
<location>project</location>
</skill>

<skill>
<name>axiom-build-debugging</name>
<description>Use when encountering dependency conflicts, CocoaPods/SPM resolution failures, "Multiple commands produce" errors, or framework version mismatches - systematic dependency and build configuration debugging for iOS projects. Includes pressure scenario guidance for resisting quick fixes under time constraints</description>
<location>project</location>
</skill>

<skill>
<name>axiom-build-performance</name>
<description>Use when build times are slow, investigating build performance, analyzing Build Timeline, identifying type checking bottlenecks, enabling compilation caching, or optimizing incremental builds - comprehensive build optimization workflows including Xcode 26 compilation caching</description>
<location>project</location>
</skill>

<skill>
<name>axiom-camera-capture</name>
<description>AVCaptureSession, camera preview, photo capture, video recording, RotationCoordinator, session interruptions, deferred processing, capture responsiveness, zero-shutter-lag, photoQualityPrioritization, front camera mirroring</description>
<location>project</location>
</skill>

<skill>
<name>axiom-camera-capture-diag</name>
<description>camera freezes, preview rotated wrong, capture slow, session interrupted, black preview, front camera mirrored, camera not starting, AVCaptureSession errors, startRunning blocks, phone call interrupts camera</description>
<location>project</location>
</skill>

<skill>
<name>axiom-camera-capture-ref</name>
<description>Reference — AVCaptureSession, AVCapturePhotoSettings, AVCapturePhotoOutput, RotationCoordinator, photoQualityPrioritization, deferred processing, AVCaptureMovieFileOutput, session presets, capture device APIs</description>
<location>project</location>
</skill>

<skill>
<name>axiom-cloud-sync</name>
<description>Use when choosing between CloudKit vs iCloud Drive, implementing reliable sync, handling offline-first patterns, or designing sync architecture - prevents common sync mistakes that cause data loss</description>
<location>project</location>
</skill>

<skill>
<name>axiom-cloud-sync-diag</name>
<description>Use when debugging 'file not syncing', 'CloudKit error', 'sync conflict', 'iCloud upload failed', 'ubiquitous item error', 'data not appearing on other devices', 'CKError', 'quota exceeded' - systematic iCloud sync diagnostics for both CloudKit and iCloud Drive</description>
<location>project</location>
</skill>

<skill>
<name>axiom-cloudkit-ref</name>
<description>Use when implementing 'CloudKit sync', 'CKSyncEngine', 'CKRecord', 'CKDatabase', 'SwiftData CloudKit', 'shared database', 'public database', 'CloudKit zones', 'conflict resolution' - comprehensive CloudKit database APIs and modern sync patterns reference</description>
<location>project</location>
</skill>

<skill>
<name>axiom-codable</name>
<description>Use when working with Codable protocol, JSON encoding/decoding, CodingKeys customization, enum serialization, date strategies, custom containers, or encountering "Type does not conform to Decodable/Encodable" errors - comprehensive Codable patterns and anti-patterns for Swift 6.x</description>
<location>project</location>
</skill>

<skill>
<name>axiom-concurrency-profiling</name>
<description>Use when profiling async/await performance, diagnosing actor contention, or investigating thread pool exhaustion. Covers Swift Concurrency Instruments template, task visualization, actor contention analysis, thread pool debugging.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-core-data</name>
<description>Use when choosing Core Data vs SwiftData, setting up the Core Data stack, modeling relationships, or implementing concurrency patterns - prevents thread-confinement errors and migration crashes</description>
<location>project</location>
</skill>

<skill>
<name>axiom-core-data-diag</name>
<description>Use when debugging schema migration crashes, concurrency thread-confinement errors, N+1 query performance, SwiftData to Core Data bridging, or testing migrations without data loss - systematic Core Data diagnostics with safety-first migration patterns</description>
<location>project</location>
</skill>

<skill>
<name>axiom-core-location</name>
<description>Use for Core Location implementation patterns - authorization strategy, monitoring strategy, accuracy selection, background location</description>
<location>project</location>
</skill>

<skill>
<name>axiom-core-location-diag</name>
<description>Use for Core Location troubleshooting - no location updates, background location broken, authorization denied, geofence not triggering</description>
<location>project</location>
</skill>

<skill>
<name>axiom-core-location-ref</name>
<description>Use for Core Location API reference - CLLocationUpdate, CLMonitor, CLServiceSession, authorization, background location, geofencing</description>
<location>project</location>
</skill>

<skill>
<name>axiom-core-spotlight-ref</name>
<description>Use when indexing app content for Spotlight search, using NSUserActivity for prediction/handoff, or choosing between CSSearchableItem and IndexedEntity - covers Core Spotlight framework and NSUserActivity integration for iOS 9+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-database-migration</name>
<description>Use when adding/modifying database columns, encountering "FOREIGN KEY constraint failed", "no such column", "cannot add NOT NULL column" errors, or creating schema migrations for SQLite/GRDB/SQLiteData - prevents data loss with safe migration patterns and testing workflows for iOS/macOS apps</description>
<location>project</location>
</skill>

<skill>
<name>axiom-deep-link-debugging</name>
<description>Use when adding debug-only deep links for testing, enabling simulator navigation to specific screens, or integrating with automated testing workflows - enables closed-loop debugging without production deep link implementation</description>
<location>project</location>
</skill>

<skill>
<name>axiom-display-performance</name>
<description>Use when app runs at unexpected frame rate, stuck at 60fps on ProMotion, frame pacing issues, or configuring render loops. Covers MTKView, CADisplayLink, CAMetalDisplayLink, frame pacing, hitches, system caps.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-energy</name>
<description>Use when app drains battery, device gets hot, users report energy issues, or auditing power consumption - systematic Power Profiler diagnosis, subsystem identification (CPU/GPU/Network/Location/Display), anti-pattern fixes for iOS/iPadOS</description>
<location>project</location>
</skill>

<skill>
<name>axiom-energy-diag</name>
<description>Symptom-based energy troubleshooting - decision trees for 'app at top of battery settings', 'phone gets hot', 'background drain', 'high cellular usage', with time-cost analysis for each diagnosis path</description>
<location>project</location>
</skill>

<skill>
<name>axiom-energy-ref</name>
<description>Complete energy optimization API reference - Power Profiler workflows, timer/network/location/background APIs, iOS 26 BGContinuedProcessingTask, MetricKit monitoring, with all WWDC code examples</description>
<location>project</location>
</skill>

<skill>
<name>axiom-extensions-widgets</name>
<description>Use when implementing widgets, Live Activities, or Control Center controls - enforces correct patterns for timeline management, data sharing, and extension lifecycle to prevent common crashes and memory issues</description>
<location>project</location>
</skill>

<skill>
<name>axiom-extensions-widgets-ref</name>
<description>Use when implementing widgets, Live Activities, Control Center controls, or app extensions - comprehensive API reference for WidgetKit, ActivityKit, App Groups, and extension lifecycle for iOS 14+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-file-protection-ref</name>
<description>Use when asking about 'FileProtectionType', 'file encryption iOS', 'NSFileProtection', 'data protection', 'secure file storage', 'encrypt files at rest', 'complete protection', 'file security' - comprehensive reference for iOS file encryption and data protection APIs</description>
<location>project</location>
</skill>

<skill>
<name>axiom-foundation-models</name>
<description>Use when implementing on-device AI with Apple's Foundation Models framework — prevents context overflow, blocking UI, wrong model use cases, and manual JSON parsing when @Generable should be used. iOS 26+, macOS 26+, iPadOS 26+, axiom-visionOS 26+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-foundation-models-diag</name>
<description>Use when debugging Foundation Models issues — context exceeded, guardrail violations, slow generation, availability problems, unsupported language, or unexpected output. Systematic diagnostics with production crisis defense.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-foundation-models-ref</name>
<description>Reference — Complete Foundation Models framework guide covering LanguageModelSession, @Generable, @Guide, Tool protocol, streaming, dynamic schemas, built-in use cases, and all WWDC 2025 code examples</description>
<location>project</location>
</skill>

<skill>
<name>axiom-getting-started</name>
<description>Use when first installing Axiom, unsure which skill to use, want an overview of available skills, or need help finding the right skill for your situation — interactive onboarding that recommends skills based on your project and current focus</description>
<location>project</location>
</skill>

<skill>
<name>axiom-grdb</name>
<description>Use when writing raw SQL queries with GRDB, complex joins, ValueObservation for reactive queries, DatabaseMigrator patterns, query profiling under performance pressure, or dropping down from SQLiteData for performance - direct SQLite access for iOS/macOS</description>
<location>project</location>
</skill>

<skill>
<name>axiom-hang-diagnostics</name>
<description>Use when app freezes, UI unresponsive, main thread blocked, watchdog termination, or diagnosing hang reports from Xcode Organizer or MetricKit</description>
<location>project</location>
</skill>

<skill>
<name>axiom-haptics</name>
<description>Use when implementing haptic feedback, Core Haptics patterns, audio-haptic synchronization, or debugging haptic issues - covers UIFeedbackGenerator, CHHapticEngine, AHAP patterns, and Apple's Causality-Harmony-Utility design principles from WWDC 2021</description>
<location>project</location>
</skill>

<skill>
<name>axiom-hig</name>
<description>Use when making design decisions, reviewing UI for HIG compliance, choosing colors/backgrounds/typography, or defending design choices - quick decision frameworks and checklists for Apple Human Interface Guidelines</description>
<location>project</location>
</skill>

<skill>
<name>axiom-hig-ref</name>
<description>Reference — Comprehensive Apple Human Interface Guidelines covering colors (semantic, custom, patterns), backgrounds (material hierarchy, dynamic), typography (built-in styles, custom fonts, Dynamic Type), SF Symbols (rendering modes, color, axiom-localization), Dark Mode, accessibility, and platform-specific considerations</description>
<location>project</location>
</skill>

<skill>
<name>axiom-icloud-drive-ref</name>
<description>Use when implementing 'iCloud Drive', 'ubiquitous container', 'file sync', 'NSFileCoordinator', 'NSFilePresenter', 'isUbiquitousItem', 'NSUbiquitousKeyValueStore', 'ubiquitous file sync' - comprehensive file-based iCloud sync reference</description>
<location>project</location>
</skill>

<skill>
<name>axiom-in-app-purchases</name>
<description>Use when implementing in-app purchases, StoreKit 2, subscriptions, or transaction handling - testing-first workflow with .storekit configuration, StoreManager architecture, transaction verification, subscription management, and restore purchases for consumables, non-consumables, and auto-renewable subscriptions</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-accessibility</name>
<description>Use when fixing or auditing ANY accessibility issue - VoiceOver, Dynamic Type, color contrast, touch targets, WCAG compliance, App Store accessibility review.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-ai</name>
<description>Use when implementing ANY Apple Intelligence or on-device AI feature. Covers Foundation Models, @Generable, LanguageModelSession, structured output, Tool protocol, iOS 26 AI integration.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-build</name>
<description>Use when ANY iOS build fails, test crashes, Xcode misbehaves, or environment issue occurs before debugging code. Covers build failures, compilation errors, dependency conflicts, simulator problems, environment-first diagnostics.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-concurrency</name>
<description>Use when writing ANY code with async, actors, threads, or seeing ANY concurrency error. Covers Swift 6 concurrency, @MainActor, Sendable, data races, async/await patterns, performance optimization.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-data</name>
<description>Use when working with ANY data persistence, database, axiom-storage, CloudKit, migration, or serialization. Covers SwiftData, Core Data, GRDB, SQLite, CloudKit sync, file storage, Codable, migrations.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-games</name>
<description>Use when building ANY 2D or 3D game, game prototype, or interactive simulation with SpriteKit, SceneKit, or RealityKit. Covers scene graphs, ECS architecture, physics, actions, game loops, rendering, SwiftUI integration, SceneKit migration.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-graphics</name>
<description>Use when working with ANY GPU rendering, Metal, OpenGL migration, shaders, 3D content, RealityKit, AR, or display performance. Covers Metal migration, shader conversion, RealityKit ECS, RealityView, variable refresh rate, ProMotion.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-integration</name>
<description>Use when integrating ANY iOS system feature - Siri, Shortcuts, Apple Intelligence, widgets, IAP, camera, photo library, photos picker, audio, axiom-haptics, axiom-localization, privacy. Covers App Intents, WidgetKit, StoreKit, AVFoundation, PHPicker, PhotosPicker, Core Haptics, App Shortcuts, Spotlight.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-ml</name>
<description>Use when deploying ANY machine learning model on-device, converting models to CoreML, compressing models, or implementing speech-to-text. Covers CoreML conversion, MLTensor, model compression (quantization/palettization/pruning), stateful models, KV-cache, multi-function models, async prediction, SpeechAnalyzer, SpeechTranscriber.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-networking</name>
<description>Use when implementing or debugging ANY network connection, API call, or socket. Covers URLSession, Network.framework, NetworkConnection, deprecated APIs, connection diagnostics, structured concurrency networking.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-performance</name>
<description>Use when app feels slow, memory grows, battery drains, or diagnosing ANY performance issue. Covers memory leaks, profiling, Instruments workflows, retain cycles, performance optimization.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-testing</name>
<description>Use when writing ANY test, debugging flaky tests, making tests faster, or asking about Swift Testing vs XCTest. Covers unit tests, UI tests, fast tests without simulator, async testing, test architecture.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-ui</name>
<description>Use when building, fixing, or improving ANY iOS UI including SwiftUI, UIKit, layout, navigation, animations, design guidelines. Covers view updates, layout bugs, navigation issues, performance, architecture, Apple design compliance.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ios-vision</name>
<description>Use when implementing ANY computer vision feature - image analysis, object detection, pose detection, person segmentation, subject lifting, hand/body pose tracking.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-liquid-glass</name>
<description>Use when implementing Liquid Glass effects, reviewing UI for Liquid Glass adoption, debugging visual artifacts, optimizing performance, or requesting expert review of Liquid Glass implementation - provides comprehensive design principles, API patterns, and troubleshooting guidance from WWDC 2025. Includes design review pressure handling and professional push-back frameworks</description>
<location>project</location>
</skill>

<skill>
<name>axiom-liquid-glass-ref</name>
<description>Use when planning comprehensive Liquid Glass adoption across an app, auditing existing interfaces for Liquid Glass compatibility, implementing app icon updates, or understanding platform-specific Liquid Glass behavior - comprehensive reference guide covering all aspects of Liquid Glass adoption from WWDC 2025</description>
<location>project</location>
</skill>

<skill>
<name>axiom-localization</name>
<description>Use when localizing apps, using String Catalogs, generating type-safe symbols (Xcode 26+), handling plurals, RTL layouts, locale-aware formatting, or migrating from .strings files - comprehensive i18n patterns for Xcode 15-26</description>
<location>project</location>
</skill>

<skill>
<name>axiom-memory-debugging</name>
<description>Use when you see memory warnings, 'retain cycle', app crashes from memory pressure, or when asking 'why is my app using so much memory', 'how do I find memory leaks', 'my deinit is never called', 'Instruments shows memory growth', 'app crashes after 10 minutes' - systematic memory leak detection and fixes for iOS/macOS</description>
<location>project</location>
</skill>

<skill>
<name>axiom-metal-migration</name>
<description>Use when porting OpenGL/DirectX to Metal - translation layer vs native rewrite decisions, migration planning, anti-patterns</description>
<location>project</location>
</skill>

<skill>
<name>axiom-metal-migration-diag</name>
<description>Use when ANY Metal porting issue occurs - black screen, rendering artifacts, shader errors, wrong colors, performance regressions, GPU crashes</description>
<location>project</location>
</skill>

<skill>
<name>axiom-metal-migration-ref</name>
<description>Use when converting shaders or looking up API equivalents - GLSL to MSL, HLSL to MSL, GL/DirectX to Metal mappings, MTKView setup code</description>
<location>project</location>
</skill>

<skill>
<name>axiom-metrickit-ref</name>
<description>MetricKit API reference for field diagnostics - MXMetricPayload, MXDiagnosticPayload, MXCallStackTree parsing, crash and hang collection</description>
<location>project</location>
</skill>

<skill>
<name>axiom-network-framework-ref</name>
<description>Reference — Comprehensive Network.framework guide covering NetworkConnection (iOS 26+), NWConnection (iOS 12-25), TLV framing, Coder protocol, NetworkListener, NetworkBrowser, Wi-Fi Aware discovery, and migration strategies</description>
<location>project</location>
</skill>

<skill>
<name>axiom-networking</name>
<description>Use when implementing Network.framework connections, debugging connection failures, migrating from sockets/URLSession streams, or adopting structured concurrency networking patterns - prevents deprecated API usage, reachability anti-patterns, and thread-safety violations with iOS 12-26+ APIs</description>
<location>project</location>
</skill>

<skill>
<name>axiom-networking-diag</name>
<description>Use when debugging connection timeouts, TLS handshake failures, data not arriving, connection drops, performance issues, or proxy/VPN interference - systematic Network.framework diagnostics with production crisis defense</description>
<location>project</location>
</skill>

<skill>
<name>axiom-networking-legacy</name>
<description>This skill should be used when working with NWConnection patterns for iOS 12-25, supporting apps that can't use async/await yet, or maintaining backward compatibility with completion handler networking.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-networking-migration</name>
<description>Network framework migration guides. Use when migrating from BSD sockets to NWConnection, NWConnection to NetworkConnection (iOS 26+), or URLSession StreamTask to NetworkConnection.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-now-playing</name>
<description>Use when Now Playing metadata doesn't appear on Lock Screen/Control Center, remote commands (play/pause/skip) don't respond, artwork is missing/wrong/flickering, or playback state is out of sync - provides systematic diagnosis, correct patterns, and professional push-back for audio/video apps on iOS 18+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-now-playing-carplay</name>
<description>CarPlay Now Playing integration patterns. Use when implementing CarPlay audio controls, CPNowPlayingTemplate customization, or debugging CarPlay-specific issues.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-now-playing-musickit</name>
<description>MusicKit Now Playing integration patterns. Use when playing Apple Music content with ApplicationMusicPlayer and understanding automatic vs manual Now Playing info updates.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-objc-block-retain-cycles</name>
<description>Use when debugging memory leaks from blocks, blocks assigned to self or properties, network callbacks, or crashes from deallocated objects - systematic weak-strong pattern diagnosis with mandatory diagnostic rules</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ownership-conventions</name>
<description>Use when optimizing large value type performance, working with noncopyable types, or reducing ARC traffic. Covers borrowing, consuming, inout modifiers, consume operator, ~Copyable types.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-performance-profiling</name>
<description>Use when app feels slow, memory grows over time, battery drains fast, or you want to profile proactively - decision trees to choose the right Instruments tool, deep workflows for Time Profiler/Allocations/Core Data, and pressure scenarios for misinterpreting results</description>
<location>project</location>
</skill>

<skill>
<name>axiom-photo-library</name>
<description>PHPicker, PhotosPicker, photo selection, limited library access, presentLimitedLibraryPicker, save to camera roll, PHPhotoLibrary, PHAssetCreationRequest, Transferable, PhotosPickerItem, photo permissions</description>
<location>project</location>
</skill>

<skill>
<name>axiom-photo-library-ref</name>
<description>Reference — PHPickerViewController, PHPickerConfiguration, PhotosPicker, PhotosPickerItem, Transferable, PHPhotoLibrary, PHAsset, PHAssetCreationRequest, PHFetchResult, PHAuthorizationStatus, limited library APIs</description>
<location>project</location>
</skill>

<skill>
<name>axiom-privacy-ux</name>
<description>Use when implementing privacy manifests, requesting permissions, App Tracking Transparency UX, or preparing Privacy Nutrition Labels - covers just-in-time permission requests, tracking domain management, and Required Reason APIs from WWDC 2023</description>
<location>project</location>
</skill>

<skill>
<name>axiom-realitykit</name>
<description>Use when building 3D content, AR experiences, or spatial computing with RealityKit. Covers ECS architecture, SwiftUI integration, RealityView, AR anchors, materials, physics, interaction, multiplayer, performance.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-realitykit-diag</name>
<description>Use when RealityKit entities not visible, anchors not tracking, gestures not responding, performance drops, materials wrong, or multiplayer sync fails</description>
<location>project</location>
</skill>

<skill>
<name>axiom-realitykit-ref</name>
<description>RealityKit API reference — Entity, Component, System, RealityView, Model3D, anchor types, material system, physics, collision, animation, audio, accessibility</description>
<location>project</location>
</skill>

<skill>
<name>axiom-realm-migration-ref</name>
<description>Use when migrating from Realm to SwiftData - comprehensive migration guide covering pattern equivalents, threading model conversion, schema migration strategies, CloudKit sync transition, and real-world scenarios</description>
<location>project</location>
</skill>

<skill>
<name>axiom-scenekit</name>
<description>Use when working with SceneKit 3D scenes, migrating SceneKit to RealityKit, or maintaining legacy SceneKit code. Covers scene graph, materials, physics, animation, SwiftUI bridge, migration decision tree.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-scenekit-ref</name>
<description>SceneKit → RealityKit concept mapping, complete API cross-reference for migration, scene graph API, materials, lighting, camera, physics, animation, constraints</description>
<location>project</location>
</skill>

<skill>
<name>axiom-sf-symbols</name>
<description>Use when implementing SF Symbols rendering modes, symbol effects, animations, custom symbols, or troubleshooting symbol appearance - covers the full symbol effects system from iOS 17 through SF Symbols 7 Draw animations in iOS 26</description>
<location>project</location>
</skill>

<skill>
<name>axiom-sf-symbols-ref</name>
<description>Use when you need complete SF Symbols API reference including every rendering mode, symbol effect, configuration option, UIKit equivalent, and platform availability - comprehensive code examples for iOS 17 through iOS 26</description>
<location>project</location>
</skill>

<skill>
<name>axiom-spritekit</name>
<description>Use when building SpriteKit games, implementing physics, actions, scene management, or debugging game performance. Covers scene graph, physics engine, actions system, game loop, rendering optimization.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-spritekit-diag</name>
<description>Use when physics contacts don't fire, objects tunnel through walls, frame rate drops, touches don't register, memory spikes, coordinate confusion, or scene transition crashes</description>
<location>project</location>
</skill>

<skill>
<name>axiom-spritekit-ref</name>
<description>SpriteKit API reference — all node types, physics body creation, action catalog, texture atlases, constraints, scene setup, particles, SKRenderer</description>
<location>project</location>
</skill>

<skill>
<name>axiom-sqlitedata</name>
<description>SQLiteData queries, @Table models, Point-Free SQLite, RETURNING clause, FTS5 full-text search, CloudKit sync, CTEs, JSON aggregation, @DatabaseFunction</description>
<location>project</location>
</skill>

<skill>
<name>axiom-sqlitedata-migration</name>
<description>Use when migrating from SwiftData to SQLiteData — decision guide, pattern equivalents, code examples, CloudKit sharing (SwiftData can't), performance benchmarks, gradual migration strategy</description>
<location>project</location>
</skill>

<skill>
<name>axiom-sqlitedata-ref</name>
<description>SQLiteData advanced patterns, @Selection column groups, single-table inheritance, recursive CTEs, database views, custom aggregates, TableAlias self-joins, JSON/string aggregation</description>
<location>project</location>
</skill>

<skill>
<name>axiom-storage</name>
<description>Use when asking 'where should I store this data', 'should I use SwiftData or files', 'CloudKit vs iCloud Drive', 'Documents vs Caches', 'local or cloud storage', 'how do I sync data', 'where do app files go' - comprehensive decision framework for all iOS storage options</description>
<location>project</location>
</skill>

<skill>
<name>axiom-storage-diag</name>
<description>Use when debugging 'files disappeared', 'data missing after restart', 'backup too large', 'can't save file', 'file not found', 'storage full error', 'file inaccessible when locked' - systematic local file storage diagnostics</description>
<location>project</location>
</skill>

<skill>
<name>axiom-storage-management-ref</name>
<description>Use when asking about 'purge files', 'storage pressure', 'disk space iOS', 'isExcludedFromBackup', 'URL resource values', 'volumeAvailableCapacity', 'low storage', 'file purging priority', 'cache management' - comprehensive reference for iOS storage management and URL resource value APIs</description>
<location>project</location>
</skill>

<skill>
<name>axiom-storekit-ref</name>
<description>Reference — Complete StoreKit 2 API guide covering Product, Transaction, AppTransaction, RenewalInfo, SubscriptionStatus, StoreKit Views, purchase options, server APIs, and all iOS 18.4 enhancements with WWDC 2025 code examples</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swift-concurrency</name>
<description>Use when you see 'actor-isolated', 'Sendable', 'data race', '@MainActor' errors, or when asking 'why is this not thread safe', 'how do I use async/await', 'what is @MainActor for', 'my app is crashing with concurrency errors', 'how do I fix data races' - Swift 6 strict concurrency patterns with actor isolation and async/await</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swift-performance</name>
<description>Use when optimizing Swift code performance, reducing memory usage, improving runtime efficiency, dealing with COW, ARC overhead, generics specialization, or collection optimization</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swift-testing</name>
<description>Use when writing unit tests, adopting Swift Testing framework, making tests run faster without simulator, architecting code for testability, testing async code reliably, or migrating from XCTest - covers @Test/@Suite macros, #expect/#require, parameterized tests, traits, tags, parallel execution, host-less testing</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftdata</name>
<description>Use when working with SwiftData - @Model definitions, @Query in SwiftUI, @Relationship macros, ModelContext patterns, CloudKit integration, iOS 26+ features, and Swift 6 concurrency with @MainActor — Apple's native persistence framework</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftdata-migration</name>
<description>Use when creating SwiftData custom schema migrations with VersionedSchema and SchemaMigrationPlan - property type changes, relationship preservation (one-to-many, many-to-many), the willMigrate/didMigrate limitation, two-stage migration patterns, and testing migrations on real devices</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftdata-migration-diag</name>
<description>Use when SwiftData migrations crash, fail to preserve relationships, lose data, or work in simulator but fail on device - systematic diagnostics for schema version mismatches, relationship errors, and migration testing gaps</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-26-ref</name>
<description>Use when implementing iOS 26 SwiftUI features - covers Liquid Glass design system, performance improvements, @Animatable macro, 3D spatial layout, scene bridging, WebView/WebPage, AttributedString rich text editing, drag and drop enhancements, and visionOS integration for iOS 26+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-animation-ref</name>
<description>Use when implementing SwiftUI animations, understanding VectorArithmetic, using @Animatable macro, zoom transitions, UIKit/AppKit animation bridging, choosing between spring and timing curve animations, or debugging animation behavior - comprehensive animation reference from iOS 13 through iOS 26</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-architecture</name>
<description>Use when separating logic from SwiftUI views, choosing architecture patterns, refactoring view files, or asking 'where should this code go', 'how do I organize my SwiftUI app', 'MVVM vs TCA vs vanilla SwiftUI', 'how do I make SwiftUI testable' - comprehensive architecture patterns with refactoring workflows for iOS 26+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-containers-ref</name>
<description>Reference — SwiftUI stacks, grids, outlines, and scroll enhancements through iOS 26</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-debugging</name>
<description>Use when debugging SwiftUI view updates, preview crashes, or layout issues - diagnostic decision trees to identify root causes quickly and avoid misdiagnosis under pressure</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-debugging-diag</name>
<description>Use when SwiftUI view debugging requires systematic investigation - view updates not working after basic troubleshooting, intermittent UI issues, complex state dependencies, or when Self._printChanges() shows unexpected update patterns - systematic diagnostic workflows with Instruments integration</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-gestures</name>
<description>Use when implementing SwiftUI gestures (tap, drag, long press, magnification, rotation), composing gestures, managing gesture state, or debugging gesture conflicts - comprehensive patterns for gesture recognition, composition, accessibility, and cross-platform support</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-layout</name>
<description>Use when layouts need to adapt to different screen sizes, iPad multitasking, or iOS 26 free-form windows — decision trees for ViewThatFits vs AnyLayout vs onGeometryChange, size class limitations, and anti-patterns preventing device-based layout mistakes</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-layout-ref</name>
<description>Reference — Complete SwiftUI adaptive layout API guide covering ViewThatFits, AnyLayout, Layout protocol, onGeometryChange, GeometryReader, size classes, and iOS 26 window APIs</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-nav</name>
<description>Use when implementing navigation patterns, choosing between NavigationStack and NavigationSplitView, handling deep links, adopting coordinator patterns, or requesting code review of navigation implementation - prevents navigation state corruption, deep link failures, and state restoration bugs for iOS 18+</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-nav-diag</name>
<description>Use when debugging navigation not responding, unexpected pops, deep links showing wrong screen, state lost on tab switch or background, crashes in navigationDestination, or any SwiftUI navigation failure - systematic diagnostics with production crisis defense</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-nav-ref</name>
<description>Reference — Comprehensive SwiftUI navigation guide covering NavigationStack (iOS 16+), NavigationSplitView (iOS 16+), NavigationPath, deep linking, state restoration, Tab+Navigation integration (iOS 18+), Liquid Glass navigation (iOS 26+), and coordinator patterns</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-performance</name>
<description>Use when UI is slow, scrolling lags, animations stutter, or when asking 'why is my SwiftUI view slow', 'how do I optimize List performance', 'my app drops frames', 'view body is called too often', 'List is laggy' - SwiftUI performance optimization with Instruments 26 and WWDC 2025 patterns</description>
<location>project</location>
</skill>

<skill>
<name>axiom-swiftui-search-ref</name>
<description>Use when implementing SwiftUI search — .searchable, isSearching, search suggestions, scopes, tokens, programmatic search control (iOS 15-18). For iOS 26 search refinements (bottom-aligned, minimized toolbar, search tab role), see swiftui-26-ref.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-synchronization</name>
<description>Use when needing thread-safe primitives for performance-critical code. Covers Mutex (iOS 18+), OSAllocatedUnfairLock (iOS 16+), Atomic types, when to use locks vs actors, deadlock prevention with Swift Concurrency.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-testflight-triage</name>
<description>Use when ANY beta tester reports a crash, ANY crash appears in Organizer or App Store Connect, crash logs need symbolication, app was killed without crash report, or you need to triage TestFlight feedback</description>
<location>project</location>
</skill>

<skill>
<name>axiom-testing-async</name>
<description>Use when testing async code with Swift Testing. Covers confirmation for callbacks, @MainActor tests, async/await patterns, timeout control, XCTest migration, parallel test execution.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-textkit-ref</name>
<description>TextKit 2 complete reference (architecture, migration, Writing Tools, SwiftUI TextEditor) through iOS 26</description>
<location>project</location>
</skill>

<skill>
<name>axiom-typography-ref</name>
<description>Apple platform typography reference (San Francisco fonts, text styles, Dynamic Type, tracking, leading, internationalization) through iOS 26</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ui-recording</name>
<description>Use when setting up UI test recording in Xcode 26, enhancing recorded tests for stability, or configuring test plans for multi-configuration replay. Based on WWDC 2025-344 "Record, replay, and review".</description>
<location>project</location>
</skill>

<skill>
<name>axiom-ui-testing</name>
<description>Use when writing UI tests, recording interactions, tests have race conditions, timing dependencies, inconsistent pass/fail behavior, or XCTest UI tests are flaky - covers Recording UI Automation (WWDC 2025), condition-based waiting, network conditioning, multi-factor testing, crash debugging, and accessibility-first testing patterns</description>
<location>project</location>
</skill>

<skill>
<name>axiom-uikit-animation-debugging</name>
<description>Use when CAAnimation completion handler doesn't fire, spring physics look wrong on device, animation duration mismatches actual time, gesture + animation interaction causes jank, or timing differs between simulator and real hardware - systematic CAAnimation diagnosis with CATransaction patterns, frame rate awareness, and device-specific behavior</description>
<location>project</location>
</skill>

<skill>
<name>axiom-using-axiom</name>
<description>Use when starting any iOS/Swift conversation - establishes how to find and use Axiom skills, requiring Skill tool invocation before ANY response including clarifying questions</description>
<location>project</location>
</skill>

<skill>
<name>axiom-vision</name>
<description>subject segmentation, VNGenerateForegroundInstanceMaskRequest, isolate object from hand, VisionKit subject lifting, image foreground detection, instance masks, class-agnostic segmentation, VNRecognizeTextRequest, OCR, VNDetectBarcodesRequest, DataScannerViewController, document scanning, RecognizeDocumentsRequest</description>
<location>project</location>
</skill>

<skill>
<name>axiom-vision-diag</name>
<description>subject not detected, hand pose missing landmarks, low confidence observations, Vision performance, coordinate conversion, VisionKit errors, observation nil, text not recognized, barcode not detected, DataScannerViewController not working, document scan issues</description>
<location>project</location>
</skill>

<skill>
<name>axiom-vision-ref</name>
<description>Vision framework API, VNDetectHumanHandPoseRequest, VNDetectHumanBodyPoseRequest, person segmentation, face detection, VNImageRequestHandler, recognized points, joint landmarks, VNRecognizeTextRequest, VNDetectBarcodesRequest, DataScannerViewController, VNDocumentCameraViewController, RecognizeDocumentsRequest</description>
<location>project</location>
</skill>

<skill>
<name>axiom-xcode-debugging</name>
<description>Use when encountering BUILD FAILED, test crashes, simulator hangs, stale builds, zombie xcodebuild processes, "Unable to boot simulator", "No such module" after SPM changes, or mysterious test failures despite no code changes - systematic environment-first diagnostics for iOS/macOS projects</description>
<location>project</location>
</skill>

<skill>
<name>axiom-xctest-automation</name>
<description>Use when writing, running, or debugging XCUITests. Covers element queries, waiting strategies, accessibility identifiers, test plans, and CI/CD test execution patterns.</description>
<location>project</location>
</skill>

<skill>
<name>axiom-xctrace-ref</name>
<description>Use when automating Instruments profiling, running headless performance analysis, or integrating profiling into CI/CD - comprehensive xctrace CLI reference with record/export patterns</description>
<location>project</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
