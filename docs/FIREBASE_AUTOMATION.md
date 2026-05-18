# Firebase Automation

This project can be operated from the CLI for the core hackathon workflow.

## Standard deploy sequence

```bash
flutter build web --release --no-tree-shake-icons
firebase deploy --only hosting
firebase deploy --only firestore,storage
firebase deploy --only remoteconfig
```

## Remote Config source of truth

- `remoteconfig.template.json`

Parameters currently managed from the repo:

- `gemini_model`
- `uma_fallback_message`
- `fraud_alert_threshold`
- `receipt_ocr_enabled`
- `wealth_autonomy_enabled`
- `statement_import_enabled`
- `max_import_transactions`

## Verified project facts

- Project ID: `vera-ai-finance`
- Hosting URL: `https://vera-ai-finance.web.app`
- Firestore DB: `(default)` in `eur3`
- Storage bucket: `vera-ai-finance.firebasestorage.app`
- Firebase apps: `vera-android`, `vera-web`

## Console-only items if CLI cannot finish them

- Cloud Billing attachment
- Google Sign-In provider enablement if an OAuth client must be created first
- Release SHA / release certificate management when needed
- Play Integrity / App Check production tuning

## Auth findings from automation

- Email/password sign-in is already enabled on the project.
- Authorized domains already include:
  - `vera-ai-finance.firebaseapp.com`
  - `vera-ai-finance.web.app`
- Android debug SHA entries are already registered in Firebase.
- Google provider creation via REST currently fails with:
  - `INVALID_CONFIG : client_id cannot be empty.`

This means the remaining Google Sign-In blocker is not domain setup or debug
SHA registration. The missing piece is the Google OAuth client/provider
configuration itself.
