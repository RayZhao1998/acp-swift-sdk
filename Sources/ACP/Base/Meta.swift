import Foundation

public enum AgentMethod: String {
  case authenticate = "authenticate"
  case initialize = "initialize"
  case sessionCancel = "session/cancel"
  case sessionFork = "session/fork"
  case sessionList = "session/list"
  case sessionLoad = "session/load"
  case sessionNew = "session/new"
  case sessionResume = "session/resume"
  case sessionSetConfigOption = "session/set_config_option"
  case sessionPrompt = "session/prompt"
  case sessionSetMode = "session/set_mode"
  case sessionSetModel = "session/set_model"
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

public enum ProtocolMethod: String {
  case cancelRequest = "$/cancel_request"
}
