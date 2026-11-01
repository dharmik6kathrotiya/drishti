# Play Console: step by step

Texts and images are in `listing.md` and the other files in this folder. The package name is `com.kaal.drishti`, and it is permanent after the first upload.

## 1. Create app

| Field | Value |
|---|---|
| App name | `Drishti: Kundli & Astrology` |
| Default language | English (India), en-IN |
| App or game | App |
| Free or paid | Free (it can never change to paid later) |
| Declarations | Tick all (Developer Program Policies, US export laws) |

## 2. App content (Dashboard → Set up your app)

| Section | Answer |
|---|---|
| Privacy policy | `https://dharmik6kathrotiya.github.io/drishti/privacy-policy.html` |
| App access | All functionality is available without special access |
| Ads | Yes, the app contains ads |
| Content rating | Email `help.kaal@gmail.com`. Category: All other app types. Answer No to violence, sexual content, language, drugs, gambling, user interaction, location sharing and digital purchases. |
| Target audience | 13–15, 16–17, 18 and over. Appeals to children: No |
| News app | No |
| Advertising ID | Yes, for advertising or marketing |
| Government app | No |
| Financial features | None |
| Health | Only a meditation or stress-relief option, if listed, for the breathing and meditation tools |

### Data safety

- Collects or shares data: Yes. The app itself collects nothing; the data below is collected by the AdMob SDK.
- Encrypted in transit: Yes.
- Deletion: the data is on the phone (Settings → Delete all data).

| Data type | Collected | Shared | Optional | Purposes |
|---|---|---|---|---|
| Approximate location | Yes | Yes | No | Advertising, fraud prevention |
| App interactions | Yes | Yes | No | Advertising, analytics |
| Crash logs, diagnostics | Yes | Yes | No | Analytics, fraud prevention |
| Device or other IDs | Yes | Yes | No | Advertising, fraud prevention |

Do not declare names, birth details or photos: they never leave the phone.

## 3. Main store listing

Copy from `listing.md`: app name, short description, full description. Upload `icon-512.png`, `feature-graphic-1024x500.png` and at least 2 phone screenshots. Store settings: category Lifestyle, tag Astrology, email `help.kaal@gmail.com`, website `https://github.com/dharmik6kathrotiya/drishti`.

## 4. Release

New personal developer accounts must first run a closed test with at least 12 testers for 14 days:

1. Testing → Closed testing → create a track, and add 12 or more testers' Gmail addresses.
2. Upload the signed `.aab` and add release notes.
3. Choose countries (India and any others).
4. Testers join through the opt-in link and stay opted in for 14 days.
5. Apply for production access from the Dashboard, then release to Production.

Keep Play App Signing on (the default). Google holds the app-signing key, and your key is only the upload key.
