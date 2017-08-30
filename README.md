# Priority API

Currently there is no way for web developers to tell the browser
about the importance of the resources that they are loading. Browsers
make many assumptions on the importance of resources based on the
resource's type (AKA its request destination), and based on its location
in the containing document.
The goal of the API and markup solutions in this specification is to
provide developers with that control.

## Use Cases

### Communicate resource importance to the browser
The browser assigns priorities and certain dependencies to downloaded
resources and uses them to determine:
* When the resource's request is sent to the server.
* What HTTP/2 dependencies and weights are assigned to the resource's
  request.

The browser uses various heuristics in order to do the above, which are
based on the type of resource, its location in the document and more.

Occasionally, web developers are in a better position to know which
resources are more impactful than others on their users' loading experience, and need a way to communicate that to the browser.

A few examples:
* Markup images are typically loaded with low/medium priority, but may
  be critical to the user experience, so for certain images, the
developer may want to indicate that their importance only falls short of
the page's render blocking resources.
* Async Javascript files may be loaded by default with low priority, but
  some of them may be of high priority and should be loaded at the same
time as the page's render blocking resources. Developers currently use
[hacks](https://twitter.com/cramforce/status/900445266750263296) to
address that use-case.
* Blocking scripts are often of high/medium priority (depends on their
  location in the page and other heuristics), yet sometimes developers
want to avoid them interfering with e.g. loading of viewport images.

### Signal a resource as non-critical
Using `<link rel=preload>` in order to get the browser to early
discover certain resources, especially in its header form,  means that the browser may discover these
resources before other, more critical resources and send their request
to the server first. That can result in loading regressions as the
server may start sending those non-critical resources before other, more
critical ones, which may fill up the TCP socket sending queues.
While better transport protocols (e.g. QUIC) may address that at a lower layer for the single origin case, developers should be able to signal to the browser that a certain resource is not critical, and therefore should be queued until such resources are discovered.

### Avoid bandwidth contention in multiple origin scenarios
When loading resources from multiple origins, setting HTTP/2
dependencies and weights do very little to avoid bandwidth contention
between the origins, as each origin tries to send down its most critical
resource without knowing of more critical resources in other origins.
Signaling resource importance to the browser can enable it to defer
sending of non-critical third party requests while critical resources
are still being downloaded.

### Provide priority signals for markup-based resources
Developers need a way to provide the above signals for resources that
are loaded through markup (or through markup-equivalent HTTP headers,
e.g. `Link:`)

### Provide priority signals for dynamically loaded resources
Developers need a way to provide the above signals for resources that
are fetched through Javascript, e.g. using the `fetch()` API.

### Provide the ability to re-prioritize a resource in-flight
"Resource priority" is not always the right way of looking at it. For
resources that are parsed on-the-fly (most notably HTML and progressive images),
their first buffer is often more important than their last. Developers
can use the ability to reprioritize resources to reflect that when
downloading such resources.

## Usage Examples

TBD
