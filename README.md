<a href="https://agentclientprotocol.com/" >
  <img alt="Agent Client Protocol" src="https://zed.dev/img/acp/banner-dark.webp">
</a>

# Agent Client Protocol (Swift)

The **unofficial** Swift implementation of the Agent Client Protocol (ACP).

> **Note**: This is an experimental/unofficial SDK and is not affiliated with the official ACP project.

Learn more at https://agentclientprotocol.com

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/acp-swift-sdk.git", branch: "main")
]
```

And add `ACP` to your target dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "ACP", package: "acp-swift-sdk")
        ]
    )
]
```

## Get Started

### Understand the Protocol

Start by reading the [official ACP documentation](https://agentclientprotocol.com) to understand the core concepts and protocol specification.

### Try the Examples

The [Sources/Example](Sources/Example) directory contains a simple implementation of an ACP Client in Swift. This example connects to a local agent (e.g., `kimi`) and demonstrates the handshake and capability negotiation.

You can run the example from your terminal:

```bash
swift run Example
```

*Note: You may need to have an ACP-compatible agent (like `kimi`) installed and available in your PATH, or configure the `ACP_AGENT_BIN` environment variable.*

## Contributing

Contributions are welcome! Please ensure your code follows the project's formatting guidelines.

### License

By contributing, you agree that your contributions will be licensed under the Apache 2.0 License.
