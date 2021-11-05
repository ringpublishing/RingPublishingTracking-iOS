1.0.1 Release notes (2021-11-04)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Features

* Added 'ErrorEvent' which is being sent in case the original event was incorrect
* Removing reported events from the queue in case of client's side issue while sending events

1.0.0 Release notes (2021-10-20)
=============================================================

Fully functional 'RingPublishingTracking' module release.

### Features

* Added 'email' parameter to the `updateUserData` method
* 'trackingIdentifier' property on `RingPublishingTracking` object is now a struct and contains `identifier` and `expirationDate` properties
* 'publicationId' parameter was added to `reportContentClick` method
* Added `reportContentClick` method variant with `aureusOfferId` parameter which should be used when interacting with Aureus recommendations

0.1.0 Release notes (2021-09-28)
=============================================================

First 'RingPublishingTracking' module release. This version is not fully functional yet, but has available complete public interface to use.

### Features

* Report application events, such as:
   - 'Click' event
   - 'User Action' event
   - 'Page View' event
   - 'Keep Alive' event
   - 'Aureus offers impression' event
   - 'Generic' event (not predefined in SDK)
* Update global tracking properties, such as:
   - user data
   - advertisement area
* Enable debug mode or opt-out mode


