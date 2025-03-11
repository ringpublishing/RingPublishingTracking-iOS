1.8.2 Release notes (2025-03-05)
================================

### Changes

* Changes for field DA and DV:
    - sending site parametr when area is inaccessible for DA
    - sending site as prefix for DV instead of root

1.8.2 Release notes (2025-03-05)
================================

### Changes

* Changes for field DA and DV:
    - sending site parametr when area is inaccessible for DA
    - sending site as prefix for DV instead of root

1.8.1 Release notes (2025-01-29)
================================

### Changes

* Changes for fields for mobile_app_fake_user_id_replaced:
    - previous_term_conversion_id -> fake_user_term_conversion_id
    - new_term_conversion_id -> real_user_term_conversion_id

1.8.0 Release notes (2025-01-24)
================================

### Changes

* Adding support for collecting information about old and new conversionId
    - before conversion from fakeUser - previous_term_conversion_id
    - after conversion for real user - new_term_conversion_id 
1.7.0 Release notes (2024-12-06)
================================

### Changes

* Audio event field VE contains hardcoded value = 6 if media type is .tts in every other case value is normal content id
1.6.5 Release notes (2024-11-06)
================================

### Changes

* Audio event field PMU contains value only if it is in UUID format

1.6.4 Release notes (2024-11-04)
================================

### Changes

* Audio event field FRA (fragment indicator) type changed from Bool to Int

1.6.3 Release notes (2024-10-28)
================================

### Changes

* Setting dx_source empty for empty publicationId

1.6.2 Release notes (2024-10-22)
================================

### Changes

* Event decorators are executed synchronously on main thread (if needed) to avoid data mismatch for "DU" and other generic parameters

1.6.1 Release notes (2024-10-16)
================================

### Changes

* Source publication uuid set to content id

1.5.3 Release notes (2024-10-03)
================================

### Changes

* IZ parameter set only when SSO system name equals 'O!Konto'

1.5.3 Release notes (2024-10-03)
================================

### Changes

* IZ parameter set based on userId fix

1.5.2 Release notes (2024-09-26)
================================

### Changes

* 'payment_method' parameter moved from 'event_details'

1.5.1 Release notes (2024-09-18)
================================

### Changes

* 'Generic' as a new analytics system name

1.5.0 Release notes (2024-09-03)
================================

Improvements to the 'RingPublishingTracking' module.

### Features

* Marking active subscriber
* Separate method to update user data
* Separate method to update SSO system name
* New method for user logout
* New event parameter - Content marked as paid
* New tracking event types for paid

1.4.0 Release notes (2023-11-16)
================================

Improvements to the 'RingPublishingTracking' module.

### Features

* Added new tracking identifier called 'Artemis'
* Public model, 'TrackingIdentifier' contains now both "EAUUID" (previously known as 'identifier') and 'Artemis' identifier
* Changed internal structure of 'RDLU' parameter

1.3.0 Release notes (2023-05-07)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Features

* Added possibility to report Video events using 'reportVideoEvent' method in 'RingPublishingTracking' class
* Added 'VideoEvent' enum
* Added 'VideoMetadata' struct
* Added 'VideoStreamFormat' enum
* Added 'VideoState' struct

1.2.4 Release notes (2023-07-31)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Changes

* User consents field (TCF2.0 string) is now part of user data in network requests instead of being part of event data.

1.2.3 Release notes (2022-06-21)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Changes

* Replaced internal KeepAlive timers implementation from 'Timer' to 'DispatchSourceTimer'. This change should not leave hanging background threads and eliminate possible deadlock with main thread

1.2.2 Release notes (2022-04-12)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Changes

* Added additional field to each request, 'RDLC' containing information that events come from native mobile app

1.2.1 Release notes (2022-04-08)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Changes

* Fix for sometimes incorrectly generated parameters "IP" and "IV" (too short)

1.2.0 Release notes (2022-03-23)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Changes

* Added required parameter 'contentId' to 'ContentMetadata'
* Renamed 'publicationId' parameter to 'contentId' in methods:
    - reportContentClick

1.1.3 Release notes (2022-03-10)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Changes

* Added new internal parameter send with each event, 'userId" with fields name: 'IZ'
* Added new internal parameter send with each 'Keep alive' event, 'PU' with article identifier

1.1.2 Release notes (2022-02-18)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Bugfix

* Fixed crash while removing events from internal queue

1.1.1 Release notes (2022-01-28)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Changes

* 'didFailToRetrieveTrackingIdentifier' method from 'RingPublishingTrackingDelegate' protocol will not be called if tracking identifier was not fetched but SDK has valid identifier stored. In this case 'didAssignTrackingIdentifier' delegate method will be called.

1.1.0 Release notes (2022-01-17)
=============================================================

Improvements to the 'RingPublishingTracking' module.

### Features

* Added 'TrackingIdentifierError' enum
* Added 'didFailToRetrieveTrackingIdentifier' method to 'RingPublishingTrackingDelegate' protocol
        This method will be called every time there was an attempt to fetch tracking identifier but it failed during module initialization (or when another attempt to fetch tracking identifier was performed)

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


