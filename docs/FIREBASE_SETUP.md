# Firebase Setup

Project:
- Firebase project id: `vera-ai-finance`
- Firestore database: `(default)` in `eur3`
- Android package: `com.vera.vera`

What is already connected:
- `Firebase Auth` for email sign-in and sign-up
- `Cloud Firestore` for:
  - `users/{uid}`
  - `users/{uid}/private/settings`
  - `users/{uid}/banks`
  - `users/{uid}/importedTransactions`
  - `users/{uid}/importArtifacts`
- Local-first fallback remains active through `flutter_secure_storage` and `SharedPreferences`
- Firestore rules are included in [firestore.rules](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/firestore.rules:1)
- Storage rules are prepared in [storage.rules](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/storage.rules:1)

Current blocker:
- `Firebase Storage` API is enabled, but the default bucket is not set up yet
- CLI deploy confirms this with:
  - `Firebase Storage has not been set up on project 'vera-ai-finance'`
- Direct Cloud Storage bucket creation is blocked because the owning project currently has no billing account attached

What to do in Firebase Console:
1. Open `https://console.firebase.google.com/project/vera-ai-finance/storage`
2. Click `Get Started`
3. Choose a Europe location such as `europe-west1`
4. If Firebase asks for billing before creating the bucket, attach a billing account and repeat the step

What happens after that:
- receipt scans can upload the original image to Storage
- statement imports can upload the original PDF/image to Storage
- upload metadata is written to Firestore under `importArtifacts`
- reset flow can clear linked artifact metadata and stored files

Verification checklist:
- sign up with email
- change a profile setting and restart the app
- add a custom bank and restart the app
- import a receipt or statement
- check Firestore collections under the signed-in user
- after Storage setup, confirm files appear under `users/{uid}/imports/...`
