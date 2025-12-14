import Foundation

public enum AgentMethod: String {
  case authenticate = "authenticate"
  case initialize = "initialize"
  case sessionCancel = "session/cancel"
  case sessionLoad = "session/load"
  case sessionNew = "session/new"
  case sessionPrompt = "session/prompt"
  case sessionSetMode = "session/set_mode"
}

public enum ClientMethod: String {
  case fsReadTextFile = "fs/read_text_file"
  case fsWriteTextFile = "fs/write_text_file"
  case sessionRequestPermission = "session/request_permission"
  case sessionUpdate = "session/update"
  case terminalCreate = "terminal/create"
  case terminalKill = "terminal/kill"
  case terminalOutput = "terminal/output"
  case terminalRelease = "terminal/release"
  case terminalWaitForExit = "terminal/wait_for_exit"
}

public let PROTOCOL_VERSION = 1
