# Priority Hints

The browser's resource loading process is a complex one. Browsers discover
needed resources and download them according to their heuristic priority.
Browsers may also use this heuristic resource priority to delay sending
certain requests in order to avoid bandwidth contention of these resources
with more critical ones.

Currently web developers have very little control over the heuristic
importance of loaded resources, other than speeding up their discovery
using `<link rel=preload>`.
Browsers make many assumptions on the importance of resources based on the
resource's type (AKA its request destination), and based on its location
in the containing document.

This document will detail use cases and an API/markup sketch that will
provide developers with the control to indicate a resource's
relative importance to the browser, and enable the browser to act on
those indications to modify the time it sends out the request and its
HTTP/2 dependency/weight so that important resources are fetched and used
earlier, in order to improve the user's experience.

### Adoption path
Markup based signal should be added in a way such that non-supporting
browsers will simply ignore them and load all resources, potentially not
in the intended priority and dependency. Script based signaling APIs
should be created in a way that non-supporting browsers simply ignore
the signals.

## Out of scope
* Signal that certain images should not block the load event
* Signals relating the script execution order, script execution
  grouping, execution dependency, etc

## Solution

We propose to address the above use-cases using the following concepts:

* We will define a new standard `importance` attribute to signal to the browser the relative importance of a resource.

* The `importance` attribute may be used with elements including link, img, script and iframe. This keyword hints to the browser the relative fetch priority a developer intends for a resource to have. Consider it an upgrade/downgrade mechanism for hinting at resource priority.

* The importance attribute will have three states that will map to current browser priorities:

  * `high` - The developer considers the resource as being high priority.
  * `low` - The developer considers the resource as being low priority.
  * `auto` - The developer does not indicate a preference. This also serves as the default value if the attribute is not specified.

* Developers would annotate resource-requesting tags such as script and link using the importance attribute as a hint of the preferred priority with which the resource should be fetched.

* Developers would be able to specify that certain resources are more or less important than others using this attribute. It would act as a hint of the intended priority rather than an instruction to the browser.

* With the `importance` attribute, the browser should make an effort to respect the developer's preference for the importance of a resource when fetching it. Note that this is intentionally weak language, allowing for a browser to apply its own preferences for resource priority or heuristics if deemed important.

* Priority Hints compliment existing browser loading primitives such as preload. Preload is a mandatory and high-priority fetch for a resource that is necessary for the current navigation. Priority Hints can hint that a resource's priority should be lower or higher than its default, and can also be used to provide more granular prioritization to preloads.

This is how we conceptually think about different resource types under the hood in browsers today.
It may translate well to user-space where different types of content share similar properties.

## Further reading

For a more complete overview of the Priority Hints proposal, please see the [draft specification](https://wicg.github.io/priority-hints/).
