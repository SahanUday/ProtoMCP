"""Analytics component - tracks pageviews and route changes."""

cl import from "react" { useEffect }
cl import from ..utils.gtag { pageview }

def:pub Analytics() -> JsxElement {
    # Track initial pageview and route changes via URL
    useEffect(
        lambda -> Any {
            # Track current page
            currentPath = window.location.pathname + window.location.search;
            pageview(currentPath);

            # Listen for route changes (SPA navigation)
            handleRouteChange = lambda -> Any {
                pageview(window.location.pathname + window.location.search);
            };

            # Listen for popstate events (back/forward buttons)
            window.addEventListener("popstate", handleRouteChange);

            # Cleanup
            return lambda -> Any {
                window.removeEventListener("popstate", handleRouteChange);
            };
        },
        []
    );

    return <span/>;
}