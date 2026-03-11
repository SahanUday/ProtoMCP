
<div align="center">

<img src="assets/mcp.png" alt="JAC MCP Playground" width="120" />

# JAC MCP Playground

**A Postman-like web UI for Model Context Protocol servers**

Connect, explore, and debug any MCP server directly from your browser. No local setup required.

[![MCP](https://img.shields.io/badge/MCP-v2024--11--05-blue?style=flat-square)](https://modelcontextprotocol.io)
[![Built with Jac](https://img.shields.io/badge/Built%20with-Jac-orange?style=flat-square)](https://jaseci.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/jaseci-labs/jac-mcp-playground?style=flat-square)](https://github.com/jaseci-labs/jac-mcp-playground/stargazers)

[Get Started](#get-started) &nbsp;·&nbsp; [Features](#features) &nbsp;·&nbsp; [Contributing](#contributing)



---

  <p>
    <a href="https://jac-mcp-playground.jaseci.org/">
      <picture>
        <source media="(prefers-color-scheme: dark)" srcset="/home/sahan/dev/jac-mcp-playground/assets/banner-dark.png">
        <source media="(prefers-color-scheme: light)" srcset="./packages/hoppscotch-common/public/images/banner-light.png">
        <img alt="Hoppscotch" src="./packages/hoppscotch-common/public/images/banner-dark.png">
      </picture>
    </a>
  </p>

</div>

## Features

### 🔌 Connect to Any MCP Server
- Enter a server URL and connect in seconds
- Supports **Streamable HTTP** (modern, session-aware) and **SSE** (legacy) transports
- Authentication: Bearer Token, API Key, Basic Auth, or none

### 🛠 Explore All Server Capabilities
- **Tools** — Execute server tools with forms auto-generated from JSON Schema
- **Prompts** — Invoke prompts with arguments and preview generated messages
- **Resources** — Browse and preview resources with MIME type detection
- **Live discovery** — All capabilities fetched and displayed instantly on connect

### 📋 Real-Time Request Logs
- Watch every JSON-RPC request and response as it happens
- Timing data per request, visual status indicators (pending / success / error)
- Full history of up to 200 requests with complete payloads

### 🗂 MCP Server Registry
- Browse official MCP servers built into the app
- Filter by transport (HTTP, SSE, STDIO) or search by name
- One-click connect to any listed server

### ⚡ Built for Developer Productivity
- Dark mode UI — comfortable for long sessions
- 3-panel layout: server list · capability explorer · live logs
- Monaco Editor (same as VS Code) for JSON payload editing
- Session ID persistence — no manual header management
- Built-in CORS proxy — no browser extension needed

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
- **Type exploration** — See tool schemas and prompt arguments visually
- **Error visibility** — Clear error messages with full response bodies
- **Session debugging** — Inspect session IDs and transport behavior

## Get Started

### Option 1 — Use the Hosted Version

No setup required. Open the playground in your browser:

**[https://jac-mcp-playground.jaseci.org/](https://jac-mcp-playground.jaseci.org/)**

### Option 2 — Run Locally

**Prerequisites**

```bash
pip install jaclang jac-client
```

**Clone and start**

```bash
git clone https://github.com/jaseci-labs/jac-mcp-playground.git
cd jac-mcp-playground
jac start main.jac
```

Open [http://localhost:8000](http://localhost:8000) in your browser.

## Usage Examples

### Connect to an MCP Server
1. Navigate to **Playground** → **Add Server**
2. Enter server URL (e.g., `https://mcp.example.com/mcp/`)
3. Select transport (Streamable HTTP recommended)
4. Add authentication if required
5. Click **Connect**

**Execute a Tool**
1. Select a connected server from the sidebar
2. Open the **Tools** tab and click any tool
3. Fill in the auto-generated form and submit
4. See the full JSON-RPC response in the logs panel

**Browse the Server Registry**
1. Navigate to **MCP Servers List**
2. Browse or search available servers
3. Click **Test Server** — the connection form opens pre-filled

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Browser                             │
│  ┌───────────┐  ┌──────────────┐  ┌─────────────────────┐   │
│  │ jac-client│  │   MCP Store  │  │  MCP Client Hook    │   │
│  │           |  │ (Context)    │  │  (JSON-RPC)         │   │
│  └─────┬─────┘  └──────┬───────┘  └──────────┬──────────┘   │
│        └───────────────┴─────────────────────┘              │
│                           │                                 │
│                       HTTP POST                             │
└───────────────────────────┼─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    Jac Runtime                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         mcp_proxy Walker (CORS Handler)             │    │
│  │  • Forward requests to MCP server                   │    │
│  │  • Handle SSE endpoint discovery                    │    │
│  │  • Stream responses line-by-line                    │    │
│  └──────────────────┬──────────────────────────────────┘    │
└─────────────────────┼───────────────────────────────────────┘
                      │
              ┌───────▼────────┐
              │  MCP Server    │
              │  (Remote)      │
              └────────────────┘
```

## Tech Stack

- **Framework**: [Jac (Jaseci)](https://jaseci.org) — Full-stack language
- **Frontend**: jac-client
- **Styling**: Tailwind CSS v4 with custom theme
- **Editor**: Monaco Editor (VS Code editor component)
- **Icons**: Lucide React
- **Deployment**: Kubernetes via jac-scale

## Why Jac?

This project is one of the first production tools built entirely in **Jac** — a full-stack language from [Jaseci Labs](https://github.com/jaseci-labs) that eliminates the frontend/backend split. The entire application — UI components, server logic, routing, and the MCP proxy — lives in a single language with a unified developer experience.

## Contributing

Contributions are welcome and appreciated! Here's how to get involved:

### Reporting Bugs

Search [existing issues](https://github.com/jaseci-labs/jac-mcp-playground/issues) first. If it's new, open one with:
- A clear title and description
- Steps to reproduce
- Expected vs. actual behavior
- Browser/OS details if relevant

### Suggesting Features

Open a [GitHub Discussion](https://github.com/jaseci-labs/jac-mcp-playground/discussions) or an issue tagged `enhancement`. Describe the use case, not just the solution.

### Submitting a Pull Request

1. **Fork** the repository and create a branch from `main`
   ```bash
   git checkout -b feat/your-feature-name
   ```

2. **Set up** your local environment
   ```bash
   pip install jaclang jac-client
   git clone https://github.com/your-username/jac-mcp-playground.git
   cd jac-mcp-playground
   jac start main.jac
   ```

3. **Make your changes** — keep commits focused and write clear messages

4. **Test** your changes locally against at least one MCP server

5. **Open a PR** against `main` with:
   - A description of what changed and why
   - Screenshots or a short recording if it's a UI change
   - Reference to the related issue (e.g. `Closes #42`)

### What to Work On

Check the [open issues](https://github.com/jaseci-labs/jac-mcp-playground/issues) for things labeled `good first issue` or `help wanted`.



## License

MIT — see [LICENSE](LICENSE) for details.

---

<div align="center">

**[Live Demo](https://jac-mcp-playground.jaseci.org/)** &nbsp;·&nbsp; [MCP Specification](https://modelcontextprotocol.io) &nbsp;·&nbsp; [Jac Docs](https://jaseci.org) &nbsp;·&nbsp; [Jaseci Labs](https://github.com/jaseci-labs)

<sub>Built with ❤️ by <a href="https://github.com/jaseci-labs">Jaseci Labs</a></sub>

</div>


