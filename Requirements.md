✅ Core Features
1. 🔥 Splash Screen + First-Time Onboarding
Branded splash screen using flutter_native_splash.

Intro onboarding screens with swipe-through interface (images + text).

"Get Started" button redirects to Sign Up/Login screen.

Onboarding state stored using shared_preferences or hive.

2. 🔐 Authentication System (Firebase)
Firebase Authentication integration:

Email & Password login

Google Sign-In

Apple Sign-In (iOS)

Anonymous Login (optional)

Token-based session persistence.

Login / Register / Forgot Password screens.

Firebase secure token refresh logic.

Reason for choosing Firebase over Clerk:
Firebase has native SDK support for Flutter, is scalable, and includes additional services (Firestore, Crashlytics, Messaging, etc.). Clerk is not officially Flutter-supported and better suited for web.

3. 🧠 AI Integration (OpenRouter)
Direct integration with OpenRouter API.

Dynamic model selection (GPT-4o, Claude 3.5, Mistral, Llama3, etc.).

Reusable service for sending prompts and receiving completions.

Token-based usage logic and error handling.

Stored securely via flutter_dotenv.

4. 🧬 Backend Integration (Neon.tech + Supabase)
Neon.tech Postgres database setup (serverless, scalable).

Supabase Edge Functions or custom backend API layer.

Secure API calls using dio or chopper.

Models, endpoints, and services structured cleanly.

5. ⚙️ Settings Panel
Profile management (name, email, avatar).

Theme toggle: Light / Dark / System.

Push notification toggle.

Language switch (multi-language support).

Account settings: Logout, Change Password, Delete Account.

6. 📲 Push Notifications
Firebase Cloud Messaging (FCM) support.

Handles:

Foreground push

Background push

App-terminated state

Device token registration + topic subscription.

🔄 Supporting Features
7. 📦 State Management
Riverpod v2+ used for reactive, scalable state control.

Async providers for auth, API, and UI state.

8. 🗃️ Local Storage
Hive or Isar used for:

Onboarding status

Caching user preferences

Token/session persistence

9. 🎨 Theming & Typography
Global theme controller (light/dark/system).

GoogleFonts integration.

Consistent typography & spacing system.

10. ⚠️ Crash Reporting & Analytics
Firebase Crashlytics for error reporting.

Firebase Analytics (optional) for user behavior tracking.

11. 🌐 Network & Offline Support
connectivity_plus integration.

Offline handling + fallback UI messages.

Optional caching of API responses.

12. 📷 Media & File Upload
image_picker for gallery/camera access.

file_picker for docs, PDFs, etc.

Upload to Supabase Storage or custom endpoint.

13. 📋 Permissions Handler
Centralized permission request manager.

Uses permission_handler for camera, location, notifications, etc.

Graceful fallbacks on denial.

14. 📱 App Version Check
Check for latest version from server.

Custom prompt to redirect to Play Store / App Store.

package_info_plus for version details.

15. 🌍 Internationalization (i18n)
Built-in multi-language support with intl.

ARB file structure.

Language toggle in settings.

16. ♻️ Reusable UI Components
Loading spinners

Toasts and snackbars

Error modals

App-wide buttons, form fields, layout containers