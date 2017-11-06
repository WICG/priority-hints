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
* We will define a new standard `importance` attribute that will map to current
  browser priorities: `critical`, `high`, `medium`, `low`, `unimportant`
* Developers would be able to assign resources into one of these importance groups or
  define resources as more or less important than said groups.
* Developers would be able to define custom importance groups, and assign
  resources to them, or define them as more or less important than said
groups
   * This is necessary in order to be able to define two "levels" of
     resource importance between existing groups.
   * This also adds a lot of complexity - what if the group definitions
     as resource attributes don't match? If a group is declared to be
fetched after a not-yet-discovered group, should the browser wait? How
long?
   * TODO: Is this use case worth the extra complexity? Any examples
     where this is required?

This is how we conceptually think about different resource types under the hood in browsers today.
It may translate well to user-space where different types of content share similar properties.

## Open questions

**Does there need to be a mechanism for limiting priorities per domain?**

Scenario: Third-party iframes could mark all of their resources as the highest priority.
This could negatively impact the performance of the top-level document or origin. 

Possible solution: each individual origin could have a priority controller for its 
connection(s) and an overall priority controller for the page load balancing them.
