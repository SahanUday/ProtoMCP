"""Central MCP server registry – add new servers here."""

def:pub getMcpServers -> list {
    return [
        {
            "id": "jac-mcp",
            "name": "Jac Language",
            "namespace": "jaseci.org",
            "transport": "http",
            "description": "Official Jac programming language MCP server. Validate, format, and convert Jac code with access to full language docs, grammar, and examples.",
            "url": "builtin://jac-mcp",
            "auth": "none",
            "authRequired": False
        },
        {
            "id": "jasketch",
            "name": "JaSketch",
            "namespace": "jasketch.jaseci.org",
            "transport": "http",
            "description": "JaSketch MCP server. Programmatically create and manipulate diagrams on a live canvas — shapes, arrows, text, and more.",
            "url": "builtin://jasketch",
            "auth": "none",
            "authRequired": False
        },
        {
            "id": "github-copilot",
            "name": "GitHub Copilot",
            "namespace": "github.com",
            "transport": "http",
            "description": "Official GitHub Copilot MCP server. Access Copilot-powered AI capabilities via Streamable HTTP.",
            "url": "https://api.githubcopilot.com/mcp/",
            "auth": "bearer",
            "authRequired": True
        },
        {
            "id": "webzum",
            "name": "WebZum",
            "namespace": "webzum.com",
            "transport": "http",
            "description": "WebZum MCP server providing web-based tools and integrations via Streamable HTTP.",
            "url": "https://webzum.com/api/mcp",
            "auth": "none",
            "authRequired": False
        },
        {
            "id": "astro-docs",
            "name": "Astro Docs",
            "namespace": "docs.astro.build",
            "transport": "http",
            "description": "Official Astro documentation MCP server. Query and explore the full Astro framework documentation.",
            "url": "https://mcp.docs.astro.build/mcp",
            "auth": "none",
            "authRequired": False
        },
        {
            "id": "exa-search",
            "name": "Exa Search",
            "namespace": "exa.ai",
            "transport": "http",
            "description": "Exa AI-powered search MCP server. Perform semantic web searches and retrieve structured results.",
            "url": "https://mcp.exa.ai/mcp",
            "auth": "none",
            "authRequired": False
        },
        {
            "id": "hugging-face",
            "name": "Hugging Face",
            "namespace": "hf.co",
            "transport": "http",
            "description": "Official Hugging Face MCP server. Access models, datasets, and AI resources from the Hugging Face hub.",
            "url": "https://hf.co/mcp",
            "auth": "none",
            "authRequired": False
        },
        {
            "id": "remote-mcp",
            "name": "Remote MCP",
            "namespace": "remote-mcp.com",
            "transport": "http",
            "description": "Remote MCP server providing remote tool execution and integration capabilities via Streamable HTTP.",
            "url": "https://mcp.remote-mcp.com",
            "auth": "none",
            "authRequired": False
        },
        {
            "id": "manifold",
            "name": "Manifold",
            "namespace": "manifold.markets",
            "transport": "http",
            "description": "Manifold Markets MCP server. Access prediction market data, questions, and trading information.",
            "url": "https://api.manifold.markets/v0/mcp",
            "auth": "none",
            "authRequired": False
        },
        {
            "id": "javadocs",
            "name": "Javadocs",
            "namespace": "javadocs.dev",
            "transport": "http",
            "description": "Javadocs MCP server. Search and query Java API documentation from across the Java ecosystem.",
            "url": "https://www.javadocs.dev/mcp",
            "auth": "none",
            "authRequired": False
        },
        {
            "id": "ferryhopper",
            "name": "Ferryhopper",
            "namespace": "ferryhopper.com",
            "transport": "http",
            "description": "Ferryhopper MCP server. Access ferry routes, schedules, and booking data across the Mediterranean.",
            "url": "https://mcp.ferryhopper.com/mcp",
            "auth": "none",
            "authRequired": False
        }
    ];
}
