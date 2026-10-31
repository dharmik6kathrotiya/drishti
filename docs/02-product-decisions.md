# Product Decisions (from Q&A, 26 Oct 2026)

## Vision
The most accurate, honest and complete astrology app. It is **100% free for users and runs at zero cost**, with optional ads as the only income. It covers **Vedic and Western** astrology, works **offline-first on the phone**, and includes an **on-phone AI helper** that explains each user's results honestly. The AI never uses fear tactics and never sells anything.

## Core principles
1. **Nobody pays.** Users never pay for anything, and the project pays for no services, APIs, astrologers or servers. Everything is built in-house or from free and open-source components. *The only unavoidable costs: Google Play developer account $25 one-time; Apple developer $99/year if we ship on iOS.*
2. **Offline-first and on-device.** Charts, daily content and the AI all run on the phone. User data stays on the phone unless the user chooses to share it or back it up.
3. **Choose, learn, or use the popular default** (see below).
4. **Honest AI.** It explains what each rule or tradition says and that it may or may not apply. No fear, no selling.

## Decisions

| Area | Decision |
|---|---|
| Market | India (Vedic) and global (Western); user chooses the system |
| Money | All features free. Ads are the only income. Users never pay |
| Ads | Fairly frequent (raised 2026-10-28): banners at the end of lists, interstitials when leaving a finished screen (max one per 2 min, 12 a day), app-open ad on returning to the app (max once an hour, 4 a day). Opt-in rewarded ad before a match result, switching or opening another person's chart, and exports (then free for 10 min; never blocks if no ad loads). *No ads inside AI explanations or while a chart is being read.* Non-personalised ads only for users under 18 |
| App | **Flutter** (Android and iOS) |
| Languages | English, Hindi, Marathi, Tamil, Telugu, Bengali, Kannada, Malayalam |
| Licence | **Open-source app (AGPL-3.0)**, which allows free use of Swiss Ephemeris |
| Chart engine | **Swiss Ephemeris** (industry standard, based on NASA JPL data) running **on the device** |
| AI | **Personal helper inside the app** that explains the user's own results. Not a separate chatbot product. **Our own fine-tuned tiny model (about 1–3B)** as an optional download, with **template explanations as the fallback** on phones that can't run it |
| AI training data | Classical texts (Sanskrit originals and out-of-copyright translations) plus synthetic Q&A; fine-tuned on free GPU resources |
| Daily horoscope | See "Daily updates at zero cost" below. Personal horoscopes come from the on-device engine; general daily content is our own free static feed |
| Backend | **No paid servers.** Only GitHub Actions and GitHub Pages (free for open-source projects) for the daily content feed |
| Profiles ("IDs") | **Unlimited profiles** (self, family, friends, celebrities, and so on). Each profile holds **only the data the user wants to give or has**. The app shows every result that data allows |
| Sharing | **QR code or share link**, sent phone to phone (WhatsApp and similar). No server |
| Login | Not required. Optional backup to the user's own Google Drive or iCloud |
| Sharing / social | **Only if the user wants.** Nothing is shared by default |
| Notifications | **Off by default.** The user turns on each type they want |
| Age | **13+ and 18+** with an age check at onboarding. Under 18: safe mode (see below) |
| Design | Several complete themes, chosen by the user |
| Launch | One big launch with all features |
| Brand | **Drishti** (working name; check Play Store, App Store, domain and trademark availability) |

## Daily updates at zero cost
**Free third-party horoscope APIs were researched and rejected for the core app:**

| Option | Problem |
|---|---|
| aztro (open source) | Old hosted endpoint, not reliably live in 2026; generic per sun sign |
| freehoroscopeapi.com | No key, but unknown owner, no SLA, content source unclear |
| Vedastro free tier | 5 requests/min, too low for an app with many users |
| Kundlit MCP | 30 requests/min per IP; meant for light use |
| Scraper projects (e.g. Zodiac repo) | Scrape other sites, which is a copyright and terms-of-service risk and breaks when the site changes |
| Newspaper horoscopes | Copyrighted; linking out sends users away |
| RapidAPI / APIVerve / Divine API free tiers | Need keys, limited free quota, paid after that |

**Our free alternative, which works like our own API:**
1. **Personal daily, weekly, monthly and yearly horoscope:** calculated **on the phone** from the user's real chart and today's transits, then turned into text from our interpretation library or by the tiny AI. Works offline with no API calls at all.
2. **General daily feed** (12 sign horoscopes, Vedic rashi and nakshatra horoscopes, festivals and vrats, panchang for major cities, "sky today" events such as retrogrades, eclipses and ingresses):
   - A **GitHub Actions** job runs once a day (free for public repos). It uses Swiss Ephemeris and our text library to generate the content for every sign and language.
   - The results are published as static JSON on **GitHub Pages** or the free **jsDelivr CDN**.
   - The app downloads the small daily file once and caches it for offline use.
3. **Panchang for the user's own location** is always calculated on the device, so it is exact for any village.

Result: daily content that updates automatically, with **no API keys, no rate limits, no copyright risk and no cost**.

## UX principle: "Choose, learn, or use the popular default"
Every astrology choice (system, ayanamsa, house system, chart style, dasha type, matching method, language and theme):
1. **The user can select it** during onboarding or later in Settings.
2. Each option has an **optional short description** behind an ⓘ "What's this?" tap. It is hidden by default, so beginners aren't overwhelmed.
3. **The most popular option is pre-selected and marked "Recommended"**, so users who don't care can just continue.

| Setting | Recommended default |
|---|---|
| Astrology system | Vedic (India locale) / Western (other locales) |
| Vedic ayanamsa | Lahiri |
| Vedic chart style | North Indian (Hindi and North India); South Indian (Tamil, Telugu, Kannada and Malayalam locales); East Indian (Bengali) |
| Western house system | **Placidus** (Whole Sign, Koch, Equal and others are selectable) |
| Vedic house system | Whole Sign (traditional Parashari) |
| Dasha | Vimshottari |
| Matching | Ashtakoot (Guna Milan) |
| Western zodiac | Tropical |

## Profiles: results based on whatever data is available
| Data the user has | What they get |
|---|---|
| Name only | Name numerology, name-based rashi (Vedic naming syllables) |
| + Date of birth | Sun sign, Moon sign (approximate if no time), numerology, life path, approximate nakshatra, daily horoscope, tarot and wellness |
| + Place of birth | Accurate timezone; Panchang at birth |
| + Exact time of birth | Full chart: Lagna, houses, divisional charts, dashas, KP and all other systems |
| Time unknown / approximate | Moon-based chart, with a clear "approximate" label, plus guided **birth-time rectification** from life events |

The app always tells the user which results become available, or more accurate, if they add more details.

## Under-18 safe mode (ages 13–17)
- Non-personalised ads only (AdMob child-directed / under-age-of-consent tags)
- No social sharing features
- AI avoids marriage timing, health predictions and other adult topics; general self-understanding only
- Data stays on the device (no backup prompts)

## AI helper principles ("no bias")
1. **The engine calculates and the AI explains.** The AI never computes positions. It only interprets facts from the engine, which prevents made-up planets and dashas.
2. **Always attributes its sources**, for example: "In Parashari astrology, Saturn in the 7th indicates X (BPHS). KP looks at the 7th cusp sub-lord instead, which here points to Z. These are traditional interpretations; they may or may not apply to you."
3. **Shows multiple traditions** where they disagree (Parashari, KP, Jaimini, Lal Kitab, Western).
4. **Tell the truth, without fear**: nothing the calculation shows is hidden or softened into something false. Difficult placements are stated plainly as "according to this calculation…", without fear words, together with protective suggestions (care, behaviour, traditional practices).
   - **Lifespan questions are answered** (decided 2026-10-28). Drishti shows the classical Jaimini three-pair longevity span (short/middle/long, with the traditional year range) and the maraka dasha periods inside that span. It explains that this is a traditional method rather than a medical fact, and that no method gives a true date of death. It adds care suggestions and points to a doctor.
   - Crisis wording ("I want to die") still gets helplines first. Teen mode does not show lifespan readings.
5. **Remedies are information only**: mantras, pujas, gemstones, rudraksha, fasting, charity and books, each with its traditional rationale. **It never names a seller or shop.**
6. **Neutral on caste, religion and gender.**
7. **Sensitive topics** (medical, legal, financial, self-harm): general answers only, and the user is pointed to qualified professionals or helplines.
8. **Personal memory, on the device**: it remembers the user's profile and past questions locally. The user can view and delete this memory.

## Feature scope (big launch)

**Charts and calculation**
- Vedic: D1–D60, Shadbala, Ashtakavarga, yogas, Vimshottari, Yogini, Chara and other dashas, Gochar, Sade Sati, Manglik, Kaal Sarp
- Ayanamsas: Lahiri (default), KP, Raman, True Chitra, Yukteshwar, Fagan-Bradley and more
- KP: cusps, star and sub lords, significators, ruling planets, horary (1–249)
- Jaimini: chara karakas, arudhas, Chara and Narayana dasha
- Lal Kitab: charts, varshphal, interpretations
- Western: tropical, all major house systems, aspects, transits, progressions, solar return, synastry, composite
- Chart styles: North, South and East Indian, plus Western wheel
- Unknown-time mode and birth-time rectification

**Daily use**
- Personalised daily, weekly, monthly and yearly horoscope (generated on the device from real transits)
- Panchang, Choghadiya, Hora, Rahu Kaal, festivals and vrat calendar
- Muhurat finder
- Optional notifications (off by default) and home-screen widgets

**Relationships**
- Kundli matching (Ashtakoot, Dashakoot, Manglik), Western synastry
- Optional sharing: compatibility cards and chart sharing only when the user chooses

**AI helper**
- An "Explain this" button on every result, plus a personal helper that answers questions about *your* results

**Wellness extras**
- Tarot, numerology, palmistry scan, meditation, journaling, mood tracking

**Remedies library (information only, no shopping)**

**Platform**
- Multiple themes, offline use, unlimited family profiles, export and delete my data

## Risks
1. **AI on the phone.** Small models (1–3B parameters) give weaker answers, especially in regional languages, and need an approximately 1–2 GB optional download. They are slow on low-end phones. *Mitigation*: the AI only explains engine facts using structured prompts, with high-quality **template explanations as a fallback** on phones that can't run it.
2. **Training data quality** (no paid astrologers). *Mitigation*: strict source attribution, conservative wording, and a test set checked against reference software and classical texts.
3. **Copyright on texts.** Use the Sanskrit originals and out-of-copyright translations only. Most modern translations (for example Santhanam's BPHS) are copyrighted.
4. **Chart engine licence.** Swiss Ephemeris is free only under AGPL, which means the whole app must be open-source. A commercial licence would cost money.
5. **One big launch** carries a high risk of a long build without user feedback. Use a closed beta before the public launch.
6. **Translation quality** in eight languages without paid translators. Use community or volunteer reviewers and an in-app "suggest better translation" option.
7. **Compliance.** DPDP Act (parental consent for under-18s if we process their data, which is why data stays on the device), ASCI (no guarantees), and Google Play and App Store policies on AI content, families and ads.

## Name ideas (availability NOT checked yet)
| Name | Meaning / why |
|---|---|
| **Akasha** | "Sky / ether" in Sanskrit; easy to say globally |
| **Vyoma** | "Sky / space"; short and premium |
| **Drishti** | "Vision / aspect", an astrology term |
| **Sitara** | "Star" in Hindi and Urdu; familiar |
| **Jyotira** | From Jyotish ("science of light") |
| **Nakshi** | A play on Nakshatra; short and modern |
| **Tara & Graha** | "Stars & planets"; covers both systems |
