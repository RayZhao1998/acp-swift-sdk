import ACP
import Foundation

@main
struct ACPKimiExampleApp {
  static func main() async {
    do {
      try await run()
    } catch {
      print("Example client failed: \(error.localizedDescription)")
    }
  }

  static func run() async throws {
    guard let agent = try locateKimiInPath() else {
      throw ExampleError.agentBinaryNotFound
    }

    let stream = try await NDJSONMessageStream.connectingProcess(
      executableURL: agent.executableURL,
      arguments: agent.arguments,
      workingDirectory: agent.workingDirectory
    )
    defer {
      Task {
        await stream.close()
      }
    }

    let client = ExampleClient()
    let connection = ClientSideConnection(toClient: { _ in client }, stream: stream)

    let _ = try await connection.initialize(
      InitializeRequest(
        protocolVersion: PROTOCOL_VERSION,
        clientCapabilities: ClientCapabilities(
          _meta: nil,
          fs: FileSystemCapability(_meta: nil, readTextFile: true, writeTextFile: true),
          terminal: true
        ),
        clientInfo: Implementation(
          name: "ACP Swift SDK Example",
          version: "1.0.0",
          title: "ACP Swift CLI",
          _meta: nil,
        ),
        _meta: nil,
      )
    )

    let cwd = FileManager.default.currentDirectoryPath

    // New Session
    let newSessionResponse = try await connection.newSession(
      NewSessionRequest(
        cwd: cwd, mcpServers: [], _meta: nil))

    let sessionId = newSessionResponse.sessionId

    // Interactive loop
    await interactiveLoop(connection: connection, sessionId: sessionId)
  }

  static func interactiveLoop(connection: ClientSideConnection, sessionId: String) async {
    while true {
      print("> ", terminator: "")
      guard let line = readLine() else { break }
      if line.isEmpty { continue }

      do {
        let promptResponse = try await connection.prompt(
          PromptRequest(sessionId: sessionId, prompt: [.text(.init(text: line))]))

        print()
        print("Prompt response received with stop reason: \(promptResponse.stopReason)")
      } catch {
        print("Prompt failed: \(error)")
      }
    }
  }
}

private enum ExampleError: LocalizedError {
  case agentBinaryNotFound

  var errorDescription: String? {
    switch self {
    case .agentBinaryNotFound:
      return "kimi CLI is missing. Install it or set ACP_AGENT_BIN to point to the binary."
    }
  }
}

private struct AgentBinary {
  let executableURL: URL
  let arguments: [String]
  let workingDirectory: URL?
}

private func locateKimiInPath() throws -> AgentBinary? {
  let which = Process()
  which.executableURL = URL(fileURLWithPath: "/usr/bin/which")
  which.arguments = ["kimi"]

  let output = Pipe()
  which.standardOutput = output

  try which.run()
  which.waitUntilExit()

  guard which.terminationStatus == 0 else { return nil }

  let data = output.fileHandleForReading.readDataToEndOfFile()
  let path = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
  guard !path.isEmpty else { return nil }

  return AgentBinary(
    executableURL: URL(fileURLWithPath: path), arguments: ["acp"], workingDirectory: nil)
}

private actor ExampleClient: Client {
  func requestPermission(params: RequestPermissionRequest) async throws -> RequestPermissionResponse
  {
    throw ACPError.methodNotFound("requestPermission")
  }

  func sessionUpdate(params: SessionNotification) async throws {
    switch params.update {
    case .agent_message_chunk(let chunk):
      let content = chunk.content
      switch content {
      case .text(let textContent):
        print(textContent.text, terminator: "")
      default:
        break
      }
    default:
      break
    }
  }
}
