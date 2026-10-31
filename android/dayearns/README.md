# DayEarns for Android

Android port of the DayEarns iOS app (Kotlin + Jetpack Compose). All data is stored on the phone in a local Room database; there is no server.

First run `sh restore_binaries.sh` once (icons + gradle wrapper jar are stored base64-encoded).

Build: `./gradlew assembleRelease` (needs a `keystore/keystore.properties` file; it is not in git). Tests: `./gradlew testReleaseUnitTest`.

## Client CSV import (Clients tab, ⋮ menu)
The first row must be a header. Required: a name column and a phone column (header names are not case-sensitive):
- Name: `Name`, `Full Name`, `Client`, `Client Name`, or `First Name` + `Last Name` (also `First`/`Last`)
- Phone: `Phone`, `Phone Number`, `Mobile`, `Cell`, `Cell Phone`, `Tel`, `Telephone`, `SDT`
Other columns are ignored. Rows with no name or no phone are skipped. Clients already saved (same name + same phone digits) are left as they are.
Export writes `Name,Phone,Email`, which can be imported again.
