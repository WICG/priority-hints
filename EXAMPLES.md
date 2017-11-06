## Usage Examples

* `<script src=foo importance=critical>` - A script is to be loaded with critical importance as it is necessary for the core user experience.
* `<img src=foo importance=high>` - An image is to be loaded with high importance. It could be important (e.g hero image, brand logo, other in-viewport image) but not critical to the overall experience loading up.
* `<link rel=preload href=foo as=image importance=medium>` - An image should be preloaded with medium importance, but not load before critical resources were discovered, as it will likely contend on bandwidth with them.
* `<link rel=preload href=foo as=image importance=critical>` - An image should be preloaded as a critical resource (e.g. potentially because the page has no other critical resources as they are all inlined)
    * That's already the default behavior of browsers in current
      implementations, but developers would be able to explicitly state that
      preference.
* `<link rel=stylesheet href=foo importance=low>` - can be used to indicate
  low importance/non-blocking style which isn't impacting the core experience. 
* `<iframe src=foo importance=low>` - would downgrade the importance of the iframe and all its subresources.
* TBD - what does the fetch API parameter look like?
* TBD - how does explicit reprioritization look like?


## Use Cases

This section outlines the different use-cases this effort sets to
address. It is worth noting that priority in these examples should not
limit itself to network priority (i.e. request time and HTTP/2
dependencies and weights), but also to processing priority, as the
browser can use the same signals in order to avoid processing of low
priority resource in favor of higher priority ones.

### Communicate resource importance to the browser
The browser assigns priorities and certain dependencies to downloaded
resources and uses them to determine:
* When the resource's request is sent to the server.
* What HTTP/2 dependencies and weights are assigned to the resource's
  request.

The browser uses various heuristics in order to do the above, which are
based on the type of resource, its location in the document and more.

Occasionally, web developers are in a better position to know which
resources are more impactful than others on their users' loading experience,
and need a way to communicate that to the browser.

A few examples:
* Markup images are typically loaded with low/medium priority, but may
  be critical to the user experience, so for certain images, the
developer may want to indicate that their importance only falls short of
the page's render blocking resources. A prominent example of that is
the page's image in an image sharing site, where the image is the
main content users are looking for. Another example is a single-page-app
where route fetches must run at highest priority.
* Async Javascript files may be loaded by default with low priority, but
  some of them may be of high priority and should be loaded at the same
time as the page's render blocking resources. Developers currently use
[hacks](https://twitter.com/cramforce/status/900445266750263296) to
address that use-case.
* Blocking scripts are often of high/medium priority (depends on their
  location in the page and other heuristics), yet sometimes developers
want to avoid them interfering with e.g. loading of viewport images.
* Third-party resources (e.g scripts from ads) are often loaded with 
medium/high priority, but developers may wish to load them all at low 
priority. Similarly, developers may wish to load all first-party 
resources that are critical with a high priority.
* When developers download a group of resources as a result of user interaction, those 
resources download priorities don't take into account the eventual usage and importance 
of those resources. Developers may wish to load these resources with priorities and 
dependencies which better represent their usage and the user's needs
* Single-page applications can kick off multiple API requests to
bootstrap the user experience. Developers may wish to load critical 
API requests at a high priority and have better control over scheduling
priority for the rest.

### Signal a resource as non-critical
Using `<link rel=preload>` in order to get the browser to early
discover certain resources, especially in its header form,  means that the
browser may discover these resources before other, more critical resources and
send their request to the server first. That can result in loading regressions
as the server may start sending those non-critical resources before other, more
critical ones, which may fill up the TCP socket sending queues.
While better transport protocols (e.g. QUIC) may address that at a lower layer
for the single origin case, developers should be able to signal to the browser
that a certain resource is not critical, and therefore should be queued until
such resources are discovered.
Such marking as "non-critical" should be orthogonal to the signaling of
the resource's "importance" (e.g. this could be applied to high priority
resources that shouldn't contend with rendering-critical resources as
well as low priority ones).

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
That would enable them both to upgrade and downgrade those resource's
"importance".

### Provide the ability to re-prioritize a resource in-flight
* "Resource priority" is not always the right way of looking at it. For
resources that are parsed on-the-fly (most notably HTML and progressive images),
their first buffer is often more important than their last. Developers
can use the ability to reprioritize resources to reflect that when
downloading such resources.
* There are also cases where the priority of a resource changes due to
  user action or condition changes. One example is the loading of
images, where in-viewport images (or soon-to-be in-viewport images) are
of higher priority than images that are further away from the viewport
and therefore less likely to be seen by the user.

### Downgrade priority of an iframe and its subresources
When developers load a third party iframe, they may wish to make sure
that it does not contend on bandwidth and/or CPU with the more important
first party content of the page. Alternatively, they may wish to
signal the browser that a certain third party iframe is as important as
the main page content and should be given CPU and bandwidth resources
accordingly.

When such a signal is applied to an iframe, it should be equally applied
to all the subresources that the iframe loads.
