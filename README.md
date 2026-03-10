# MCP Playground

A Postman-style interactive playground for **Model Context Protocol (MCP)** servers — explore, test, and debug MCP servers directly from your browser.

[![MCP](https://img.shields.io/badge/MCP-v2024--11--05-blue)](https://modelcontextprotocol.io)
[![Jac](https://img.shields.io/badge/Built%20with-Jac-orange)](https://jaseci.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Features

### 🔌 Universal MCP Server Connectivity
- **Connect to any MCP server** via URL — whether public or private
- **Dual transport support**:
  - **Streamable HTTP** — Modern, session-aware transport (recommended)
  - **SSE (Legacy)** — Server-Sent Events for older MCP servers
- **Multiple authentication methods**:
  - Bearer Token (OAuth2/JWT)
  - API Key with custom header
  - Basic Auth (Base64)
  - No authentication for public servers

### 🛠️ Complete Capability Exploration
- **Tools** — Execute server tools with auto-generated forms from JSON Schema
- **Prompts** — Invoke contextual prompts with arguments and preview generated messages
- **Resources** — Browse exposed resources with content preview and MIME type detection
- **Real-time discovery** — All capabilities fetched and displayed instantly upon connection

### 📊 Live Request/Response Logging
- **Real-time JSON-RPC logs** — Watch every request and response as it happens
- **Timing data** — See how long each request takes
- **Status indicators** — Visual feedback for pending, success, and error states
- **Full history** — Access up to 200 recent requests with complete payloads

### 🎨 Beautiful, Modern UI
- **Dark mode by default** — Easy on the eyes for long debugging sessions
- **Responsive design** — Works seamlessly on desktop, tablet, and mobile
- **3-panel playground layout** — Server sidebar, capability explorer, and logs panel
- **Smooth animations** — Polished transitions and micro-interactions
- **Monaco Editor integration** — For editing JSON payloads and viewing code

### 🚀 Official MCP Server Registry
- Browse **official MCP servers** from the registry
- Filter by transport type (HTTP, SSE, STDIO)
- Search by name, namespace, or description
- **One-click testing** — Connect to any listed server instantly

### 🔒 CORS-Friendly Architecture
- **Built-in proxy walker** — Handles CORS automatically for cross-origin requests
- **Session persistence** — Maintains MCP session IDs across requests
- **Browser-based** — No local installation required for testing remote servers

## Advantages

### Compared to CLI Tools
- **Visual interface** — No need to remember JSON-RPC commands
- **Auto-generated forms** — Tool parameters presented as form fields, not raw JSON
- **Multiple connections** — Test several servers simultaneously
- **Shareable URLs** — Send connections to teammates

### Compared to Other MCP Clients
- **Full protocol support** — Tools, prompts, and resources in one place
- **Transport flexibility** — Switch between HTTP and SSE without code changes
- **Zero setup** — Open in browser and start testing
- **Built-in registry** — Discover official servers without searching documentation

### Developer Experience
- **Hot reload** — Changes reflect instantly during development
- **Type exploration** — See tool schemas and prompt arguments visually
- **Error visibility** — Clear error messages with full response bodies
- **Session debugging** — Inspect session IDs and transport behavior

## What Makes It Unique

### Built with Jac (Jaseci Framework)
This is one of the first **production MCP tools built entirely in Jac** — a revolutionary full-stack language that combines:
- **Frontend** — React-like components (`cl` blocks)
- **Backend** — Server-side walkers (`walker:pub`)
- **Single language** — No context switching between JS/Python/Go

### Postman-Inspired for MCP
Just as Postman revolutionized API testing, MCP Playground brings the same experience to Model Context Protocol servers:
- **Collection management** — Organize your MCP servers
- **Environment switching** — Test against different servers
- **Request history** — Reuse and inspect previous calls

### Session-Aware Architecture
Unlike simple HTTP clients, MCP Playground **understands MCP sessions**:
- Captures and reuses `mcp-session-id` headers
- Handles SSE endpoint discovery automatically
- Manages session lifecycle per connection

## Quick Start

### Prerequisites
```bash
# Install Jaseci CLI
pip install jaclang jac-client
```

### Development
```bash
# Clone the repository
git clone https://github.com/jaseci-labs/jac-mcp-playground.git
cd jac-mcp-playground

# Start development server
jac start main.jac
```

Visit `http://localhost:8000` to start exploring MCP servers.

### Deployment (Kubernetes)
```bash
# Deploy to your Kubernetes cluster
jac start main.jac --scale
```

## Usage Examples

### Connect to an MCP Server
1. Navigate to **Playground** → **Add Server**
2. Enter server URL (e.g., `https://mcp.example.com/mcp/`)
3. Select transport (Streamable HTTP recommended)
4. Add authentication if required
5. Click **Connect**

### Execute a Tool
1. Select a connected server
2. Go to **Tools** tab
3. Click on any tool
4. Fill in the auto-generated form
5. See the response instantly in the logs panel

### Browse Official Registry
1. Navigate to **MCP Servers List**
2. Browse available servers
3. Click **Test Server** on any entry
4. Pre-filled connection form opens automatically

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Browser                              │
│  ┌───────────┐  ┌──────────────┐  ┌─────────────────────┐  │
│  │   React   │  │   MCP Store  │  │  MCP Client Hook    │  │
│  │  (cl)     │  │ (Context)    │  │  (JSON-RPC)         │  │
│  └─────┬─────┘  └──────┬───────┘  └──────────┬──────────┘  │
│        └────────────────┴──────────────────────┘           │
│                           │                                  │
│                    HTTP POST                                 │
└───────────────────────────┼──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│                    Jac Runtime                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         mcp_proxy Walker (CORS Handler)             │    │
│  │  • Forward requests to MCP server                   │    │
│  │  • Handle SSE endpoint discovery                    │    │
│  │  • Stream responses line-by-line                    │    │
│  └──────────────────┬──────────────────────────────────┘    │
└─────────────────────┼────────────────────────────────────────┘
                      │
              ┌───────▼────────┐
              │  MCP Server    │
              │  (Remote)      │
              └────────────────┘
```

## Tech Stack

- **Framework**: [Jac (Jaseci)](https://jaseci.org) — Full-stack language
- **Frontend**: React-like components via `cl` blocks
- **Styling**: Tailwind CSS v4 with custom theme
- **Editor**: Monaco Editor (VS Code editor component)
- **Icons**: Lucide React
- **Deployment**: Kubernetes via jac-scale

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License — see [LICENSE](LICENSE) for details.

## Links

- [MCP Specification](https://modelcontextprotocol.io)
- [Jac Documentation](https://jaseci.org)
- [Jaseci Labs](https://github.com/jaseci-labs)
