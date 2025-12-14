import Foundation

public protocol MessageStream: Sendable {
  func read() async throws -> JSONRPCMessage?
  func write(_ message: JSONRPCMessage) async throws
}

public protocol ClosableStream: Sendable {
  func close() async
}

public actor NDJSONMessageStream: MessageStream, ClosableStream {
  private var iterator: AsyncLineSequence<FileHandle.AsyncBytes>.AsyncIterator
  private let writeBytes: @Sendable (Data) throws -> Void
  private let onClose: @Sendable () -> Void
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private var isClosed = false

  public init(
    lines: AsyncLineSequence<FileHandle.AsyncBytes>,
    writeBytes: @escaping @Sendable (Data) throws -> Void,
    onClose: @escaping @Sendable () -> Void = {}
  ) {
    self.iterator = lines.makeAsyncIterator()
    self.writeBytes = writeBytes
    self.onClose = onClose
  }

  public static func fromHandles(
    input: FileHandle,
    output: FileHandle,
    onClose: @escaping @Sendable () -> Void = {}
  ) -> NDJSONMessageStream {
    NDJSONMessageStream(
      lines: input.bytes.lines,
      writeBytes: { data in output.write(data) },
      onClose: {
        output.closeFile()
        onClose()
      }
    )
  }

  public static func connectingProcess(
    executableURL: URL,
    arguments: [String],
    workingDirectory: URL? = nil
  ) async throws -> NDJSONMessageStream {
    let process = Process()
    process.executableURL = executableURL
    process.arguments = arguments
    process.currentDirectoryURL = workingDirectory

    let stdoutPipe = Pipe()
    let stdinPipe = Pipe()

    process.standardOutput = stdoutPipe
    process.standardError = FileHandle.standardError
    process.standardInput = stdinPipe

    try process.run()

    return NDJSONMessageStream.fromHandles(
      input: stdoutPipe.fileHandleForReading,
      output: stdinPipe.fileHandleForWriting,
      onClose: {
        stdinPipe.fileHandleForWriting.closeFile()
        process.terminate()
      }
    )
  }

  public func read() async throws -> JSONRPCMessage? {
    var iteratorCopy = iterator
    guard let line = try await iteratorCopy.next() else {
      iterator = iteratorCopy
      return nil
    }
    iterator = iteratorCopy

    guard !line.isEmpty else { return try await read() }
    guard let data = line.data(using: .utf8) else { return nil }
    return try decoder.decode(JSONRPCMessage.self, from: data)
  }

  public func write(_ message: JSONRPCMessage) async throws {
    var data = try encodeMessage(message)
    data.append(0x0a)
    try writeBytes(data)
  }

  public func close() async {
    guard !isClosed else { return }
    isClosed = true
    onClose()
  }

  private func encodeMessage(_ message: JSONRPCMessage) throws -> Data {
    switch message {
    case .request(let request):
      return try encoder.encode(request)
    case .notification(let notification):
      return try encoder.encode(notification)
    case .response(let response):
      switch response {
      case .success(let successResponse):
        return try encoder.encode(successResponse)
      case .failure(let failureResponse):
        return try encoder.encode(failureResponse)
      }
    }
  }
}
