# MindSanctuary - System overview (technical summary)

MindSanctuary is a non-clinical, university-centered wellbeing SaaS built with Phoenix LiveView for reactive UI and Phoenix Channels for anonymous peer chat. Core subsystems:

* Auth & Identity (student and volunteer roles; anonymous chat identity).

* Mood Tracker (daily check-ins, simple analytics).

* Resource Hub (audio files, articles, contact info — university-tagged).

* Anonymous Peer Support (real-time chat pairing students with volunteers).

* Events / Workshops (listing, RSVP, calendar export).

* Admin & Volunteer dashboard (manage resources, see queue, moderate).

* Background workers (deliver digests, schedule pairing, generate analytics).

## Priority (MVP-first)

MVP features (build first):

1. Auth (university email sign-up + role selection).

2. Mood Tracker with simple timeline view.

3. Resource Hub (text + audio streaming via signed URLs).

4. Anonymous peer chat pairing + chat UI (one-to-one).

5. Volunteer Dashboard: see active queue & accept chats.

6. Basic moderation/reporting flow and profanity filtering.
Stretch (add later):

  * Calendar integration / notifications.

  * Scheduled workshops & RSVP reminders.

  * Sentiment analytics / charts.

  * Rich media uploads by volunteers.

  * SSO with university (SAML/OAuth).


# Endpoints & LiveViews (minimal list)

* `/` — landing LiveView
* `/auth/*` — registration/login via generated auth
* `/mood` — Mood tracker LiveView + POST endpoint
* `/resources` — Resource hub LiveView
* `/resources/new`, `/resources/:id/edit` — Admin LiveViews
* `/chat` — Request chat / join queue component (LiveView or form)
* `/volunteer/dashboard` — volunteer LiveView (queue + active)
* `/chat/:id` — chat LiveView that connects to Channel topic
* `/events` — Event listing LiveView
* `/admin` — Admin dashboard (flags, usage metrics)

# Suggested task list (prioritized)

1. Initialize Phoenix project + Ecto + Postgres + phx.gen.auth.
2. Create `User` schema + roles and volunteer availability.
3. Build MoodEntry schema + LiveView check-in.
4. Resources CRUD (admin-only) + listing UI.
5. Chat tables + basic queue creation.
6. Phoenix Channel for `chat:<id>` and basic message send/receive.
7. Volunteer dashboard + Presence.
8. Pairing worker (Oban job) or GenServer to match queued chats to volunteers.
9. Moderation/report endpoint + admin view for flags.
10. S3 integration for resource audio.
11. Deploy to staging and run simple demo.

# Quick checklist (shareable)

* [ ] Phoenix app scaffolded
* [ ] PostgreSQL + Ecto configured
* [ ] Authentication implemented
* [ ] Mood tracker UI and DB
* [ ] Resource hub CRUD + audio streaming
* [ ] Anonymous chat models + channels
* [ ] Volunteer dashboard + Presence
* [ ] Pairing worker (Oban)
* [ ] Moderation/reporting UI
* [ ] Deployable release + CI
* [ ] Basic tests for critical flows

# Final pragmatic advice (philosophy + craft)

* Keep the MVP *tiny* but end-to-end: one complete story (auth → mood → chat) is far better than many half-finished features. Examiners like working demos.
* Treat anonymity as a first-class requirement — if you compromise that, the whole project loses credibility.
* Write tests for the matching logic — that’s the part most likely to have race conditions.
* Use LiveView for most UI to minimize JS surface area; add JS only if absolutely necessary for UX.