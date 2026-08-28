# Evidence recording script (UGC — Apple 1.2)

Apple asks for a recording **captured on a physical device** that shows (1) the terms/EULA consent before sign-up or login, (2) reporting content, (3) blocking a user. Simulator recordings are refused.

## Prepare
- A physical iPhone (recent iOS). Settings > Control Center > add "Screen Recording".
- Demo accounts A (reviewer) and B (the other side) are friends; B has sent A a few messages (one of them is the one you'll report).
- Kill the app; start logged out.
- Under 2–3 minutes. No captions or editing needed; one continuous take.

## Sequence
1. Start recording from Control Center → launch the app from the home screen (icon visible).
2. Login screen: pause on the consent checkbox/screen → open the terms link and show the "no tolerance" / "24 hours" clause for ~3 s → close.
3. Accept and log in as A (typing the password may be off-screen).
4. Open friends / chat → long-press (or ⋯) on B's message → **Report** → pick a reason → submit → confirmation.
5. B's profile → **Block** → confirm → show B's content disappearing **instantly** from the chat / friends list.
6. Settings > Blocked users shows B.
7. (Optional) Settings > Delete account exists; Settings > Contact.
8. Stop recording.

## Android (Play)
- Same sequence on a physical device: `adb shell screenrecord /sdcard/ugc.mp4` or the built-in recorder.
- Sensitive-permission / foreground-service declaration videos are separate: permission prompt → user grants → the core feature that uses it.

## Submitting
- Apple: attach the file in the App Review message reply (attachments allowed) **and** put a link (Drive/Dropbox/unlisted YouTube, no login required) in App Review Information > Notes. Keep the link for later submissions.
- Play: link in App access "Other instructions" and in the declaration forms' video URL field.
