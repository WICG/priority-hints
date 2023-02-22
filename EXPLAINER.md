# Priority Hints

The browser's resource loading process is a complex one. Browsers discover
needed resources and download them according to their heuristic priority.
Browsers may also use this heuristic resource priority to delay sending
certain requests in order to avoid bandwidth contention of these resources
with more critical ones.

Browsers make many assumptions on the priority of resources based on the
resource's type (AKA its request destination), and based on its location
in the containing document.

This document will detail use cases and show how developers can indicate a
resource's relative priority to the browser for the browser to use when making
loading prioritization decisions.

It is important to note that changing the priority of one resource usually
comes at the cost of another resource so hints should be applied sparingly.
Marking everything in the document as high-priority will likely make for a worse
user experience but correctly tagging a few resources that the browser would
otherwise not load optimally can have a huge benefit.

### Adoption path
The markup signals and script APIs are backward-compatible in that
non-supporting browsers will simply ignore them and load all resources as they
normally would without the additional hints.

## Out of scope
* Anything besides an initial priority signal for the loading of the
  indicated resource
* Signal that certain images should not block the load event
* Signals relating the script execution order, script execution
  grouping, execution dependency, etc

## Solution

Priority Hints addresses the above use-cases using the following concepts:

* A [`fetchpriority` attribute](https://html.spec.whatwg.org/multipage/urls-and-fetching.html#fetch-priority-attribute) to signal to the browser the relative priority of a resource.

* The [`fetchpriority` attribute](https://html.spec.whatwg.org/multipage/urls-and-fetching.html#fetch-priority-attribute) may be used with elements including [link](https://html.spec.whatwg.org/multipage/semantics.html#attr-link-fetchpriority), [img](https://html.spec.whatwg.org/multipage/embedded-content.html#attr-img-fetchpriority) and [script](https://html.spec.whatwg.org/multipage/scripting.html#attr-script-fetchpriority). This keyword hints to the browser the relative fetch priority a developer intends for a resource to have. Consider it an upgrade/downgrade mechanism for hinting at resource priority.

* The [`fetchpriority` attribute](https://html.spec.whatwg.org/multipage/urls-and-fetching.html#fetch-priority-attribute) has three states that will influence the current browser priorities:

  * [`high`](https://html.spec.whatwg.org/multipage/urls-and-fetching.html#attr-fetchpriority-high) - The developer considers the resource as being important relative to the default priority for resources of the same type.
  * [`low`](https://html.spec.whatwg.org/multipage/urls-and-fetching.html#attr-fetchpriority-low) - The developer considers the resource as being less important relative to the default priority for resources of the same type.
  * [`auto`](https://html.spec.whatwg.org/multipage/urls-and-fetching.html#attr-fetchpriority-auto) - The developer does not indicate a preference and defers to the browser's default heuristics. This also serves as the default value if the attribute is not specified.

* With the [`fetchpriority` attribute](https://html.spec.whatwg.org/multipage/urls-and-fetching.html#fetch-priority-attribute), the browser should make an effort to respect the developer's preference for the priority of a resource when fetching it. Note that this is intentionally weak language, allowing for a browser to apply its own preferences for resource priority or heuristics if deemed important.

* Priority Hints compliment existing browser loading primitives such as preload. Preload is a mandatory fetch for a resource that is necessary for the current navigation. Priority Hints can hint that a resource's priority should be lower or higher than its default, and can also be used to provide more granular prioritization to preloads.

* The JavaScript fetch() API exposes the priority hint as a [`priority` property of RequestInit](https://fetch.spec.whatwg.org/#dom-requestinit-priority) using the same `high`, `low` and `auto` values as the HTML [`fetchpriority` attribute](https://html.spec.whatwg.org/multipage/urls-and-fetching.html#fetch-priority-attribute).

This is how we conceptually think about different resource types under the hood in browsers today.
It may translate well to user-space where different types of content share similar properties.

## Example use cases

### Signal High-Priority Images
A browser may normally load images in the order the appear in the document, possibly increasing the priority after layout when it can determine the position and vissibility of an image (i.e. making visible in-viewport images load sooner). A priority hint on the image element itself can provide a parse-time signal to the browser to fetch important images, like the main product image in a product detail page, sooner or de-prioritize hidden images like later images in an image carousel.

```html
...
<img src=logo.png>
<img src=footer.png>
<img src=product.jpg fetchpriority=high>
<img src=product-carousel-2.jpg fetchpriority=low>
...
```

### Signal Priority of Asynchronous Scripts
A browser may treat parser-blocking scripts, async scripts and preloaded scripts differently based on heuristics that work well in a general case but may not behave exactly as a developer desires.

For example, if a browser treats preloaded scripts as high-priority and async scripts as low priority by default, it could be difficult to preload a dependency of an async script and still have them load in the desired order. For example, if we have a script ```a.js``` that imports ```b.js```, it could be useful to preload b.js so the fetch can start in parallel with the loading of a.js. A trivial implementation of preloading the dependency after the main script:

```html
<script src=a.js async></script>
<link rel=preload href=b.js as=script>
```

may result in b.js being loaded before a.js in a browser where preloaded scripts are given a higher priority than async scripts.

By using priority hints and assigning the same priority to both scripts, they can be loaded in the preferred order and at a priority that makes sense depending on the context of what the script is being used for (say, high priority for user-facing UI or functionality or low-priority for scripts responsible for background work).

```html
<script src=a.js async fetchpriority=high></script>
<link rel=preload href=b.js as=script fetchpriority=high>
```

### Signal Priority of Fetch API Calls
fetch() API calls without priority hints are prioritized equally because the browser has no way to get context into the relative priority of one API call over another. A case where this can be a problem is in the case of JavaScript that responds to user input while background activity is going on.

For example, assume we have an endpoint ```autocomplete.json``` that is used to provide type-down autocomplete suggestions as a user types into a text box and another endpoint ```prefetch.json``` that is used to download and cache background data that may be used at some point in the future. Without priority hints, any calls to ```autocomplete.json``` will compete equally for priority, server response and bandwidth. With priority hints, the interactive API calls to ```autocomplete.json``` can get prioritized ahead of the background API calls and if the underlying connection protocol supports prioritization, the relative priority can be carried through to the connection layer and server.

```javascript
...

// Start prefetching content for possible user interaction and offline support
fetch('/api/prefetch.json', { priority: 'low' }).then(/*...*/)

...

// Handle autocomplete of user keypresses
function autocomplete() {
  fetch('/api/autocomplete.json', { priority: 'high' }).then(/*...*/)
}

...
```
