---
name: Equestrian App Gap Analysis
overview: Comprehensive gap analysis and implementation plan covering database schema, backend APIs, admin UI/UX redesign, mobile app completion, and deployment on Railway (backend + MySQL) and Vercel Pro (admin frontend), with repo separation and TestFlight pipeline.
todos:
  - id: db-schema
    content: "Phase 1: Database schema changes - new models (Notification, LessonBooking, HorseAvailability, LessonPackage, RiderPackageBalance, CourseTemplate, SessionFeedback) and field additions to Horse, User, Stable, Arena, CourseSession"
    status: pending
  - id: booking-api
    content: "Phase 2A: Build lesson booking flow API - 10 new endpoints covering stable/coach/slot selection, horse request, approval chain, and payment"
    status: pending
  - id: horse-availability
    content: "Phase 2B: Horse availability system - daily session limits, availability calendar, date blocking"
    status: pending
  - id: course-templates-feedback
    content: "Phase 2C: Course templates, session feedback APIs, and course drawing/image upload system (backend storage for drawn courses and uploaded course layout images)"
    status: pending
  - id: course-drawing-web
    content: "Phase 3D: Course drawing canvas in admin panel using tldraw (infinite canvas SDK) - coaches can draw course layouts or upload images, saved as JSON + PNG export to backend"
    status: pending
  - id: course-drawing-mobile
    content: "Phase 4E: Course drawing canvas in mobile app using flutter_drawing_board - coaches can draw or upload course layout images, export as PNG to backend"
    status: pending
  - id: lesson-packages
    content: "Phase 2D: Lesson packages API - coach creates packages, rider purchases"
    status: pending
  - id: notifications-api
    content: "Phase 2E: Notifications API + emit notifications on key events"
    status: pending
  - id: admin-api-enhancements
    content: "Phase 2F-2H: Admin analytics, payment management, stable/coach approvals, stable dashboard, coach dashboard APIs"
    status: pending
  - id: admin-ui-redesign
    content: "Phase 3A: Admin dashboard UI/UX overhaul - new dashboard layout with revenue/booking/approval widgets, AreaChart, ComposedChart, quick actions, and pending approvals feed"
    status: pending
  - id: admin-design-system
    content: "Phase 3B: Admin design system upgrade - extract reusable DataTable component with TanStack Table, improve dark mode, add responsive card/table views, enhance sidebar with grouped nav and notification bell"
    status: pending
  - id: admin-new-pages
    content: "Phase 3C: Build new admin pages - Payments, Payouts, Settings, Profile, Analytics, Notifications; enhance existing pages with approvals and verification"
    status: pending
  - id: mobile-wire-services
    content: "Phase 4A: Mobile app - wire all services to screens, fix bugs (landing nav, forgot password, profile links), replace all hardcoded data"
    status: pending
  - id: mobile-new-screens
    content: "Phase 4B: Mobile app - build missing screens (booking flow, course view, performance history, notifications, coach features)"
    status: pending
  - id: mobile-tappay
    content: "Phase 4C: Mobile app - TapPay SDK integration and push notifications (FCM)"
    status: pending
  - id: mobile-models
    content: "Phase 4D: Mobile app - create typed Dart model classes for all entities"
    status: pending
  - id: deployment-railway
    content: "Phase 5A: Deploy backend + MySQL on Railway with Docker, configure env vars, S3/R2 for file uploads"
    status: pending
  - id: deployment-vercel
    content: "Phase 5B: Deploy frontend-admin on Vercel Pro with vercel.json SPA rewrites, env vars for API URL"
    status: pending
  - id: repo-separation
    content: "Phase 5C: Split monorepo into equestrian-platform (backend + admin) and equestrian-mobile repos, set up Cursor multi-root workspace"
    status: pending
  - id: ios-testflight
    content: "Phase 5D: iOS TestFlight pipeline - fix bundle ID, set up Fastlane, GitHub Actions workflow for IPA build and upload"
    status: pending
  - id: future-features
    content: "Phase 6 (future): Competition management, horse marketplace, auction, equipment marketplace, rider public profiles and rankings"
    status: pending
isProject: false
---

# Equestrian Platform - Combined Implementation Plan

## Current State Summary

The codebase is a **monorepo** with three apps:

- **backend/** - Node.js/Express/Sequelize/MySQL, ~104 endpoints, 15 models, Docker-ready
- **frontend-admin/** - React 19/Vite 7/Tailwind v4, functional CRUD pages, basic dashboard
- **mobile-app/** - Flutter 3.24, UI scaffolding with hardcoded data, services exist but unwired

## Infrastructure Decisions (Confirmed)

- **Database**: Railway MySQL (zero code changes to Sequelize, visual SQL editor, same project as backend)
- **Backend hosting**: Railway (auto-deploy from GitHub, Docker support already done via existing `Dockerfile`)
- **Admin frontend**: Vercel Pro (perfect for Vite/React SPA)
- **Repo structure**: 2 repos in Cursor multi-root workspace (clean separation, both editable from one window)
- **Mobile builds**: Local Xcode + CI/CD via GitHub Actions (Flutter CI already partially set up)
- **File storage**: Cloudflare R2 or AWS S3 (current local `upload/` directory won't work in production)

---

## Phase 1: Database Schema Changes

All changes in [backend/models/](backend/models/) and [backend/config/schema-updates.js](backend/config/schema-updates.js).

### New Models to Create

- **Notification** - `id`, `user_id`, `admin_id` (nullable), `type` (enum: lesson_booked, session_reminder, payment_confirmed, horse_assigned, horse_approved, feedback_posted), `title`, `body`, `data` (JSON), `is_read` (BOOLEAN), `created_at`
- **LessonBooking** - `id`, `rider_id`, `coach_id`, `stable_id`, `arena_id` (nullable), `horse_id` (nullable), `session_id` (nullable FK to CourseSession), `booking_date` (DATEONLY), `start_time` (TIME), `end_time` (TIME), `lesson_type` (enum: private/group), `status` (enum: pending_horse_approval, pending_payment, confirmed, cancelled, completed), `payment_id` (nullable), `price` (DECIMAL), `created_at`, `updated_at`
- **HorseAvailability** - `id`, `horse_id`, `date` (DATEONLY), `max_sessions_per_day` (INTEGER), `sessions_booked` (INTEGER), `is_available` (BOOLEAN)
- **LessonPackage** - `id`, `coach_id`, `title`, `description`, `lesson_count` (INTEGER), `price` (DECIMAL), `validity_days` (INTEGER), `is_active` (BOOLEAN)
- **RiderPackageBalance** - `id`, `rider_id`, `package_id`, `remaining_lessons` (INTEGER), `expires_at` (DATE)
- **CourseTemplate** - `id`, `coach_id`, `name`, `difficulty` (enum), `obstacles` (JSON), `distances` (JSON), `arena_layout` (JSON), `notes` (TEXT), `is_active` (BOOLEAN)
- **SessionFeedback** - `id`, `session_id`, `coach_id`, `rider_id`, `feedback_text` (TEXT), `performance_rating` (TINYINT 1-5), `areas_to_improve` (JSON), `created_at`
- **PlatformSetting** - `id`, `key` (STRING UNIQUE), `value` (JSON), `updated_at` -- for platform fees, commission rates, etc.

### Existing Model Field Additions

- **Horse** ([backend/models/horse.model.js](backend/models/horse.model.js)): `age`, `training_level` (enum), `temperament`, `injury_notes`, `rider_suitability`, `fei_pedigree_link`, `max_daily_sessions` (default 3)
- **User** ([backend/models/user.model.js](backend/models/user.model.js)): `fei_number`, `riding_level` (enum) for riders; `specialties` (JSON), `bio`, `is_verified` (default false) for coaches; `fcm_token` (STRING) for push notifications
- **Stable** ([backend/models/stable.model.js](backend/models/stable.model.js)): `rating` (DECIMAL), `lesson_price_min`, `lesson_price_max`, `is_approved` (default false)
- **Arena** ([backend/models/arena.model.js](backend/models/arena.model.js)): `is_active` (default true)
- **CourseSession** ([backend/models/courseSession.model.js](backend/models/courseSession.model.js)): `horse_id` (FK), `arena_id` (FK), `course_template_id` (nullable)

---

## Phase 2: Backend API Additions

### 2A - Lesson Booking Flow (NEW)

New files: `backend/routes/booking.routes.js`, `backend/controllers/booking.controller.js`, `backend/services/booking.service.js`


| Endpoint                                                     | Purpose                                                        |
| ------------------------------------------------------------ | -------------------------------------------------------------- |
| `GET /api/v1/bookings/stables`                               | Nearby stables with rating, arena availability, price range    |
| `GET /api/v1/bookings/stables/:id/coaches`                   | Coaches at a stable with specialties, ratings, available times |
| `GET /api/v1/bookings/coaches/:id/slots?date=`               | Available time slots for a coach on a date                     |
| `GET /api/v1/bookings/stables/:id/horses?discipline=&level=` | Available horses filtered by suitability                       |
| `POST /api/v1/bookings`                                      | Create booking (stable, coach, date/time, horse)               |
| `PATCH /api/v1/bookings/:id/approve-horse`                   | Coach approves horse assignment                                |
| `PATCH /api/v1/bookings/:id/confirm-horse`                   | Stable confirms horse availability                             |
| `POST /api/v1/bookings/:id/pay`                              | Process payment and confirm booking                            |
| `GET /api/v1/bookings/my`                                    | Rider's bookings                                               |
| `GET /api/v1/bookings/coach/my`                              | Coach's bookings                                               |
| `PATCH /api/v1/bookings/:id/cancel`                          | Cancel booking                                                 |


### 2B - Horse Availability System

Add to [backend/routes/horse.routes.js](backend/routes/horse.routes.js):

- `GET /api/v1/horses/:id/availability?month=` - Horse availability calendar
- `PUT /api/v1/horses/:id/availability` - Set daily session limits
- `POST /api/v1/horses/:id/block-dates` - Block specific dates

### 2C - Course Templates, Feedback, and Course Drawing/Image System

Add to course and session routes:

- `POST /api/v1/courses/templates` - Save course as template
- `GET /api/v1/courses/templates` - List coach's templates
- `POST /api/v1/courses/from-template/:templateId` - Create from template
- `POST /api/v1/sessions/:id/feedback` - Coach logs feedback
- `GET /api/v1/sessions/:id/feedback` - Get feedback
- `GET /api/v1/riders/:id/performance` - Aggregated performance history

**Course Drawing/Image endpoints** (for the course layout feature):

- `POST /api/v1/courses/:id/layout` - Upload course layout (accepts both image file and JSON drawing data)
- `GET /api/v1/courses/:id/layout` - Get course layout (returns image URL + drawing JSON)
- `PUT /api/v1/courses/:id/layout` - Update course layout
- `DELETE /api/v1/courses/:id/layout` - Remove course layout

**New fields on CourseTemplate model:**

- `layout_image_url` (STRING) - stored PNG/JPG of the course layout (uploaded or exported from canvas)
- `layout_drawing_data` (JSON) - serialized drawing data from tldraw/flutter_drawing_board for re-editing

**Upload middleware addition** in [backend/middleware/upload.middleware.js](backend/middleware/upload.middleware.js):

```javascript
export const uploadCourseLayout = createImageUpload(courseLayoutDir, 'layout_image', {
  fileSize: 10 * 1024 * 1024, // 10MB for high-res drawings
  allowedTypes: ['image/png', 'image/jpeg', 'image/jpg'],
});
```

**How it works:**

1. Coach draws a course on the canvas OR uploads a photo/sketch
2. If drawn: canvas exports both a PNG (for display) and JSON (for re-editing later)
3. Both are sent to backend: PNG stored as file, JSON stored in `layout_drawing_data`
4. Riders see the PNG image; coaches can re-open and edit using the JSON data
5. Templates save the layout data so it can be reused across courses

### 2D - Lesson Packages

New files: `backend/routes/package.routes.js`, `backend/controllers/package.controller.js`, `backend/services/package.service.js`

- `POST /api/v1/packages` - Coach creates package
- `GET /api/v1/packages/coach/:id` - Coach's packages
- `POST /api/v1/packages/:id/purchase` - Rider purchases
- `GET /api/v1/packages/my` - Rider's active packages

### 2E - Notifications

New files: `backend/routes/notification.routes.js`, `backend/controllers/notification.controller.js`, `backend/services/notification.service.js`

- `GET /api/v1/notifications` - User notifications (paginated)
- `PATCH /api/v1/notifications/:id/read` - Mark as read
- `PATCH /api/v1/notifications/read-all` - Mark all read
- `GET /api/v1/notifications/unread-count` - Unread count

Emit notifications on: booking created, horse approved, payment confirmed, session reminder, feedback posted. Add `firebase-admin` for push notifications to mobile.

### 2F - Admin Enhancements

Add to [backend/routes/admin.routes.js](backend/routes/admin.routes.js):

- `GET /api/v1/admin/analytics` - Rider growth, booking volume, revenue metrics (date-ranged)
- `GET /api/v1/admin/payments` - All payments with filters
- `GET /api/v1/admin/payouts` - Coach payout management
- `POST /api/v1/admin/payouts/:id/process` - Process payout
- `PATCH /api/v1/admin/stables/:id/approve` - Approve/reject stable
- `PATCH /api/v1/admin/coaches/:id/verify` - Verify/reject coach
- `GET /api/v1/admin/settings` - Platform settings
- `PUT /api/v1/admin/settings` - Update platform settings
- `GET /api/v1/admin/bookings` - All bookings with filters

### 2G - Stable Dashboard APIs

New route file (authenticated stable admin):

- `GET /api/v1/stable-dashboard/overview` - Lessons, revenue, horse utilization
- `GET /api/v1/stable-dashboard/arena-schedule` - Arena bookings calendar
- `GET /api/v1/stable-dashboard/revenue` - Financial breakdown
- `GET /api/v1/stable-dashboard/horses/utilization` - Horse usage stats

### 2H - Coach Dashboard APIs

Add to coach routes:

- `GET /api/v1/coaches/me/dashboard` - Today's riders, upcoming sessions, earnings
- `GET /api/v1/coaches/me/earnings` - Earnings breakdown

---

## Phase 3: Admin Frontend - UI/UX Overhaul

The current admin is functional but basic. This phase transforms it into a polished, production-ready dashboard.

### Current State Assessment

After thorough review of every admin page and component:

**What works well:**

- Dark mode infrastructure (ThemeProvider + ThemeContext + Tailwind `dark:` variants throughout)
- Amber/orange brand color is distinctive and consistent
- Mobile drawer sidebar with Framer Motion animations
- Consistent card styling (`rounded-2xl`, `border-gray-200`, `bg-white dark:bg-gray-900`)
- Working CRUD for all core entities

**What needs improvement:**

- Dashboard only shows entity counts + enrollment trend chart (no revenue, no bookings, no pending actions)
- Data tables are hand-rolled `<table>` elements with basic Prev/Next pagination (no sorting, no column filtering, no inline edit)
- No responsive card fallback for tables on mobile (tables overflow on small screens)
- `Card` component uses undefined CSS classes (`card`, `card-title`) and is unused
- No notification bell or unread count in header
- No breadcrumbs for detail pages
- Charts limited to single enrollment trend (no revenue, no bookings, no horse utilization)
- No admin profile/settings page
- Sidebar has no grouped sections or badges

### 3A - Dashboard Redesign

Redesign [frontend-admin/src/pages/admin/AdminDashboardPage.jsx](frontend-admin/src/pages/admin/AdminDashboardPage.jsx):

**New dashboard layout (top to bottom):**

1. **Welcome header** (keep existing greeting, add date and "Last refreshed" timestamp)
2. **KPI row** - 4 primary metric cards in a responsive grid:
  - Total Revenue (with % change from last month) - uses `AreaChart` sparkline
  - Active Bookings (with % change) - uses mini `BarChart`
  - Total Riders (with growth indicator)
  - Total Coaches (with verified/unverified count)
   Each card: gradient top border, icon, big number, sparkline or delta badge, "View all" link
3. **Two-column section:**
  - **Left (2/3 width)**: Revenue + Bookings `ComposedChart` (Area for revenue, Bar for bookings) with daily/weekly/monthly toggle. Replace the single-metric enrollment chart with this combined view
  - **Right (1/3 width)**: "Pending Actions" card:
    - Stables awaiting approval (count + "Review" link)
    - Coaches awaiting verification (count + "Review" link)
    - Pending payouts (count + "Process" link)
    - Each row: icon, label, count badge, action link
4. **Three-column section:**
  - **Entity distribution** `PieChart` (stables, arenas, horses, disciplines) -- replace existing mini pie charts
  - **Recent bookings** feed (last 5 bookings: rider name, coach, date, status badge)
  - **Top coaches** leaderboard (by rating or sessions count)
5. **Bottom section**: Keep enrollment trends chart but enhance:
  - Add `AreaChart` option alongside existing `BarChart` and `LineChart`
  - Use gradient fills under area curves
  - Add better tooltip formatting with Recharts custom tooltip

**Recharts components to use** (already installed as dependency):

- `ComposedChart` for combined revenue + bookings
- `AreaChart` with `linearGradient` fill for sparklines and trends
- `PieChart` for entity distribution
- `BarChart` with `radius` for rounded bars
- `ResponsiveContainer` wrapping all charts

**Implementation approach**: All Recharts components are available (project already uses `recharts`). Use `useMemo` for data transformation to prevent re-renders.

### 3B - Design System Upgrade

#### Reusable DataTable Component

Create `frontend-admin/src/components/ui/DataTable.jsx` using **TanStack Table v8** (headless):

```
npm install @tanstack/react-table
```

The component should provide:

- **Column sorting** (click header to sort asc/desc, sort indicator arrows)
- **Column filtering** (per-column filter inputs in header)
- **Global search** (replace current per-page search implementations)
- **Server-side pagination** (Prev/Next + page numbers, rows per page selector)
- **Row selection** with checkboxes (for bulk actions)
- **Responsive mode**: on screens < `md`, render as stacked cards instead of table rows
- **Loading skeleton**: animated placeholder rows while fetching
- **Empty state**: icon + message + CTA button
- **Inline status editing**: click status badge to open dropdown (for approvals, verification)

This replaces the hand-rolled tables in: `AdminCoachesPage`, `AdminRidersPage`, `AdminArenasPage`, `AdminHorsesPage`, `AdminDisciplinesPage`, `AdminCoursesPage`, `AdminStablesPage`, `CourseSessionsTable`, `CourseEnrollmentsTable`.

#### Fix Card Component

Replace unused CSS-class-based `Card` in [frontend-admin/src/components/ui/Card.jsx](frontend-admin/src/components/ui/Card.jsx) with a Tailwind-styled version matching existing card patterns:

```jsx
const Card = ({ title, subtitle, accent, actions, className = '', children }) => (
  <section className={`relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900 ${className}`}>
    {accent && <div className={`absolute inset-x-0 top-0 h-1 bg-gradient-to-r ${accent}`} />}
    {(title || actions) && (
      <div className="mb-4 flex items-center justify-between">
        <div>
          {title && <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">{title}</h2>}
          {subtitle && <p className="text-sm text-gray-500 dark:text-gray-400">{subtitle}</p>}
        </div>
        {actions && <div className="flex items-center gap-2">{actions}</div>}
      </div>
    )}
    {children}
  </section>
);
```

#### Enhanced Sidebar Navigation

Update [frontend-admin/src/components/layout/AdminAppLayout.jsx](frontend-admin/src/components/layout/AdminAppLayout.jsx):

**Grouped navigation sections:**

```
MAIN
  Dashboard
  Bookings (NEW)

MANAGEMENT
  Stables
  Arenas
  Horses
  Disciplines

PEOPLE
  Coaches (with unverified count badge)
  Riders

LEARNING
  Courses

FINANCE (NEW section)
  Payments
  Payouts

SYSTEM (NEW section)
  Analytics
  Settings
```

**Header enhancements:**

- Add notification bell icon with unread count badge (red dot or number)
- Add breadcrumbs below header for detail pages (e.g., "Coaches > John Smith")
- Replace static "Operations Overview" title with dynamic page title from route

#### Dark Mode Polish

Current dark mode works but has a few issues:

- The `dark:bg-bg-amber-900/25` typo in sidebar active state (double `bg-`) needs fixing
- Chart colors are hardcoded (amber `#f59e0b`, emerald `#10b981`) and don't adapt to dark mode
- Add Recharts custom theme: lighter grid lines in dark mode, adjusted label colors
- Ensure all status badges have proper dark mode variants

#### Image Management

Improve `ImageCropperModal` workflow:

- Add drag-and-drop upload zone (using existing `react-easy-crop` + HTML5 drag events)
- Show image preview thumbnails in table rows (already partial)
- Add "Remove image" button on edit forms

### 3C - New Admin Pages


| Page                       | Route                  | Key Components                                                                               |
| -------------------------- | ---------------------- | -------------------------------------------------------------------------------------------- |
| **AdminBookingsPage**      | `/admin/bookings`      | DataTable with booking status filters, rider/coach/stable columns, date range picker         |
| **AdminPaymentsPage**      | `/admin/payments`      | DataTable with payment status, provider, amount, date range; export CSV                      |
| **AdminPayoutsPage**       | `/admin/payouts`       | DataTable with payout status, bulk "Process" action, individual approve/reject               |
| **AdminSettingsPage**      | `/admin/settings`      | Form sections: Platform fees (%), commission rates, TapPay config, SMTP settings             |
| **AdminProfilePage**       | `/admin/profile`       | Profile form (name, email), password change form (uses existing `changeAdminPassword` thunk) |
| **AdminAnalyticsPage**     | `/admin/analytics`     | Date range picker, revenue chart, rider growth chart, booking heatmap, top coaches/stables   |
| **AdminNotificationsPage** | `/admin/notifications` | Notification list with read/unread, filter by type, mark all read                            |


### Existing Pages to Enhance

- **AdminCoachesPage**: Add "Verified" badge column, "Verify" / "Reject" action buttons, filter dropdown (All / Verified / Unverified)
- **AdminStablesPage** / **AdminStableViewPage**: Add "Approved" badge, "Approve" / "Reject" actions, financial summary tab in stable view
- **AdminCoursesPage**: Add "Delete" and "Archive" action buttons
- **AdminRidersPage**: Add riding level column, FEI number column

### 3D - Course Drawing Canvas (Admin Panel)

**Library**: [tldraw](https://tldraw.dev/) v4.4 - actively maintained infinite canvas SDK for React, used by ClickUp, Padlet, etc.

```
npm install tldraw
```

Create `frontend-admin/src/components/admin/courses/CourseLayoutEditor.jsx`:

**Two modes:**

1. **Draw mode** - tldraw canvas with drawing tools (pen, shapes, lines, text, arrows). Coach draws obstacle layout, distances, notes directly on canvas.
2. **Upload mode** - Drag-and-drop zone (reuse pattern from `ImageCropperModal`). Coach uploads a photo or scan of a hand-drawn course.

**Component behavior:**

- Toggle between "Draw" and "Upload" tabs
- Draw mode: embed `<Tldraw />` component with controlled store. On save, export canvas as PNG via `editor.exportImage()` and get JSON via `editor.store.getSnapshot()`
- Upload mode: image upload with preview (same pattern as horse/arena image upload)
- "Save Layout" button sends both PNG file and JSON data to `POST /api/v1/courses/:id/layout`
- When reopening: if `layout_drawing_data` exists, restore tldraw store from JSON snapshot. If only image, show read-only image view
- Read-only view for riders/admins who just need to see the layout image

**Integration points:**

- `AdminCourseDetailsPage` - add "Course Layout" section with `CourseLayoutEditor`
- `AdminCourseCreatePage` - add layout editor as optional step
- `CourseOverviewCard` - show layout image thumbnail if exists

**Follows existing patterns:**

- Same `Modal` wrapper for full-screen editing
- Same `toast.success` / `toast.error` for feedback
- Same `operationsApi` pattern for API calls (`saveCourseLayoutApi`, `getCourseLayoutApi`)
- Same `toFormData` for multipart upload

### 3E - Frontend Admin CI

Add `.github/workflows/frontend-ci.yml`:

- Trigger: push/PR to `main` when `frontend-admin/`** changes
- Steps: checkout, setup Node 20, `npm ci`, `npm run lint` (add eslint script), `npm run build`

---

## Phase 4: Mobile App Completion

All changes in [mobile-app/lib/](mobile-app/lib/).

### 4A - Critical Bug Fixes and Service Wiring

**Bugs to fix immediately:**

1. `LandingScreen` "Create Account" navigates to `LoginScreen` instead of `SignupScreen`
2. Forgot password handler is empty (`onPressed: () {}`)
3. `ProfileScreen` menu items (Booking History, Achievements, Payment & Subscription, Settings) don't navigate anywhere
4. `SubscriptionScreen` is unreachable from any navigation

**Service wiring** - replace hardcoded data with API calls:

- `SelectHorseScreen` -> use `HorseService.getPublicHorses()`
- `ChooseCoachScreen` -> use `CoachService.getPublicCoaches()`
- `PickTimeScreen` -> use `CoachService.getCoachUpcomingAvailability()`
- `HorsesScreen` -> use `StableService.getPublicStables()` + `HorseService.getPublicHorses()`
- `CoursesScreen` -> use `CourseService.getCourses()`
- `CoachHomeScreen` -> use `SessionService.getMySessions()`

### 4B - New Screens

**Rider screens:**


| Screen                    | Purpose                                                |
| ------------------------- | ------------------------------------------------------ |
| StableSelectionScreen     | Step 1 - browse stables with ratings, prices, distance |
| CoachSelectionScreen      | Step 2 - coaches at stable, specialties, ratings       |
| DateTimeSelectionScreen   | Step 3 - calendar with real coach availability slots   |
| HorseRequestScreen        | Step 4 - available horses with suitability info        |
| PaymentScreen             | Step 5 - TapPay integration, package selection         |
| BookingConfirmationScreen | Post-payment confirmation with lesson details          |
| LessonDayScreen           | Active session view (assigned course, horse, arena)    |
| CourseViewScreen          | Today's course (obstacle layout, instructions, notes)  |
| PerformanceHistoryScreen  | Feedback and progress over time                        |
| MyCoachesScreen           | Rider's coaches list                                   |
| NotificationsScreen       | In-app notification feed                               |
| BookingHistoryScreen      | Past and upcoming bookings                             |
| SettingsScreen            | App settings                                           |
| ProfileEditScreen         | Edit profile with photo upload                         |


**Coach screens:**


| Screen                         | Purpose                                               |
| ------------------------------ | ----------------------------------------------------- |
| CoachDashboardScreen (enhance) | Today's riders, assigned horses, earnings summary     |
| CourseBuilderScreen            | Create/edit courses with obstacles, distances, layout |
| SessionFeedbackScreen          | Log feedback after session                            |
| CoachEarningsScreen            | Earnings breakdown                                    |
| LessonPackageScreen            | Create and manage lesson packages                     |


### 4C - Course Drawing Canvas (Mobile App)

**Library**: [flutter_drawing_board](https://pub.dev/packages/flutter_drawing_board) - cross-platform, supports pen/shapes/eraser, undo/redo, JSON serialization, PNG export.

```yaml
# pubspec.yaml
flutter_drawing_board: ^latest
```

Create `mobile-app/lib/features/courses/screens/course_layout_editor_screen.dart`:

**Two modes (same as web):**

1. **Draw mode** - `DrawingBoard` widget with pen, shapes, eraser, undo/redo. Coach draws course layout on phone/tablet.
2. **Upload mode** - `image_picker` to select photo from gallery or camera (hand-drawn sketch, printed diagram).

**Component behavior:**

- Tab bar: "Draw" | "Upload Photo"
- Draw mode: `DrawingBoard` with configurable pen color, width, shapes. On save: export as PNG via `getImageData()` and get JSON via `getJsonList()`
- Upload mode: `ImagePicker().pickImage()` with preview
- "Save" button in `AppBar` sends PNG + JSON to backend
- When reopening: restore drawing from JSON via `addContents()`, or show uploaded image
- Read-only mode for riders: just display the PNG image using `CachedNetworkImage`

**Follows existing patterns:**

- Same `AppScaffold` layout
- Same `ApiService` for HTTP calls
- Same `PrimaryButton` for actions
- Same `AppColors` and `AppTextStyles`
- Same error handling with `mounted` checks
- File names: `course_layout_editor_screen.dart`, `course_layout_service.dart`

**Integration points:**

- `CourseBuilderScreen` (new) - includes layout editor
- `CourseViewScreen` (new) - shows layout image to riders
- `CoachHomeScreen` - link to course builder

### 4D - TapPay and Push Notifications

**TapPay**: Add `go_sell_sdk_flutter` to `pubspec.yaml`, create `TapPayService`, wire into `PaymentScreen`

**Push notifications**: Add `firebase_messaging` + `flutter_local_notifications`, create `NotificationService` for FCM token registration. Backend stores FCM tokens and sends push via `firebase-admin` SDK.

### 4E - Typed Data Models

Create model classes in `mobile-app/lib/core/models/` instead of raw `Map<String, dynamic>`:

`Coach`, `Horse`, `Stable`, `Arena`, `Course`, `Session`, `Booking`, `Payment`, `Notification`, `Discipline`, `LessonPackage`, `SessionFeedback`

Each with `fromJson()` factory and `toJson()` method.

---

## Phase 5: Deployment and Infrastructure

### 5A - Backend on Railway

**Railway project setup:**

1. Create Railway project with two services: **Backend** (Docker) + **MySQL** database
2. Connect GitHub repo, Railway auto-detects `backend/Dockerfile`
3. Railway MySQL provides env vars: `MYSQL_URL`, `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`
4. Map Railway MySQL vars to app's expected vars in Railway's service settings:
  - `DB_HOST` = `${{MySQL.MYSQLHOST}}`
  - `DB_PORT` = `${{MySQL.MYSQLPORT}}`
  - `DB_USER` = `${{MySQL.MYSQLUSER}}`
  - `DB_PASSWORD` = `${{MySQL.MYSQLPASSWORD}}`
  - `DB_NAME` = `${{MySQL.MYSQLDATABASE}}`
5. Set remaining env vars: `JWT_SECRET`, `SMTP_`*, `ADMIN_INVITE_SECRET`, `NODE_ENV=production`, `FRONTEND_URL_PROD`
6. Generate public domain in Railway Settings > Networking

**File storage migration:**

- Replace local `upload/` with Cloudflare R2 (S3-compatible, cheaper than AWS S3)
- Install `@aws-sdk/client-s3` + `multer-s3` in backend
- Update [backend/middleware/upload.middleware.js](backend/middleware/upload.middleware.js) to upload to R2
- Update [backend/utils/file.util.js](backend/utils/file.util.js) to return R2 URLs
- Set env vars: `S3_ENDPOINT`, `S3_BUCKET`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`

### 5B - Frontend Admin on Vercel Pro

**Vercel configuration:**

Add `vercel.json` to repo root:

```json
{
  "buildCommand": "cd frontend-admin && npm run build",
  "outputDirectory": "frontend-admin/dist",
  "rewrites": [{ "source": "/(.*)", "destination": "/" }]
}
```

Vercel auto-detects Vite framework. The `rewrites` rule handles SPA client-side routing (prevents 404 on direct URL access to routes like `/admin/coaches`).

**Environment variables in Vercel dashboard:**

- `VITE_API_BASE_URL` = Railway backend URL (e.g., `https://equestrian-backend.up.railway.app/api/v1`)

### 5C - Repository Separation

Split into two repos, both open in a **Cursor multi-root workspace**:

```
Repo 1: equestrian-platform
├── backend/
├── frontend-admin/
├── .github/workflows/
│   ├── backend-ci.yml          (existing, move here)
│   ├── frontend-ci.yml         (NEW)
│   └── deploy-backend.yml      (NEW - Railway auto-deploy via GitHub)
├── vercel.json
├── .gitignore
└── README.md

Repo 2: equestrian-mobile
├── lib/                        (mobile-app/lib/ contents)
├── ios/
├── android/
├── assets/
├── pubspec.yaml
├── .github/workflows/
│   ├── flutter-ci.yml          (existing, adjust paths)
│   └── ios-testflight.yml      (NEW)
├── fastlane/
│   └── Fastfile
├── Gemfile
├── .gitignore
└── README.md
```

**Cursor multi-root workspace file** (`equestrian.code-workspace`):

```json
{
  "folders": [
    { "path": "../equestrian-platform", "name": "Platform (Backend + Admin)" },
    { "path": "../equestrian-mobile", "name": "Mobile App" }
  ]
}
```

### 5D - iOS TestFlight Pipeline

**Prerequisites:**

- Apple Developer Program account ($99/year)
- App record in App Store Connect
- App Store Connect API key (for CI)

**Steps:**

1. Fix iOS bundle identifier: change from `horse_riding_app_design` to `com.equestrian.app` in `ios/Runner.xcodeproj` and `Info.plist`
2. Update display name from "Horse Riding App Design" to "Equestrian"
3. Add `Gemfile` to mobile repo root:

```ruby
source "https://rubygems.org"
gem "fastlane", ">= 2.232.0"
gem "cocoapods", ">= 1.16.2"
```

1. Create `fastlane/Fastfile`:

```ruby
default_platform(:ios)
platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    setup_ci
    app_store_connect_api_key(
      key_id: ENV["APPSTORE_KEY_ID"],
      issuer_id: ENV["APPSTORE_ISSUER_ID"],
      key_content: ENV["APPSTORE_PRIVATE_KEY"]
    )
    build_app(
      workspace: "ios/Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_testflight(skip_waiting_for_build_processing: true)
  end
end
```

1. Create `.github/workflows/ios-testflight.yml`:
  - Trigger: push to `main` or manual dispatch
  - Runner: `macos-latest`
  - Steps: checkout, setup Flutter 3.24, `flutter build ipa --release`, import certificates (from GitHub Secrets), run `fastlane beta`
2. GitHub Secrets needed: `CERTIFICATES_P12`, `CERTIFICATES_P12_PASSWORD`, `APPSTORE_ISSUER_ID`, `APPSTORE_KEY_ID`, `APPSTORE_PRIVATE_KEY`, `APPLE_TEAM_ID`

---

## Phase 6: Future Features (Separate Phases)

After the core platform is stable:

- **Competition Management** - `Competition`, `CompetitionEntry`, `CompetitionResult` models. Event location selection, paid entry, results/scoring.
- **Horse Marketplace** - `MarketplaceListing` (sell/rent). Auto-transfer button on horse profile.
- **Auction System** - Bidding engine, time-limited auctions, real-time updates.
- **Equipment Marketplace** - Product listings, cart, checkout.
- **Rider Public Profiles and Rankings** - Public profile pages, leaderboards from aggregated performance data.

---

## Execution Priority Order


| Priority | Task                                                      | Depends On                     |
| -------- | --------------------------------------------------------- | ------------------------------ |
| 1        | Database schema changes                                   | --                             |
| 2        | Lesson booking flow API                                   | Schema                         |
| 3        | Horse availability system                                 | Schema                         |
| 4        | Admin UI/UX overhaul (dashboard redesign + design system) | -- (can parallel with 2-3)     |
| 5        | Wire mobile app services + fix bugs                       | Booking API                    |
| 6        | Notifications (backend + mobile)                          | Schema                         |
| 7        | Course templates, feedback, and drawing API               | Schema                         |
| 7b       | Course drawing canvas - admin panel (tldraw)              | Course API (7)                 |
| 7c       | Course drawing canvas - mobile (flutter_drawing_board)    | Course API (7)                 |
| 8        | Admin new pages (Payments, Analytics, Settings)           | Admin APIs (2F)                |
| 9        | Mobile new screens (booking flow, coach features)         | Booking API + Notifications    |
| 10       | Deployment setup (Railway + Vercel)                       | -- (can parallel with 4-9)     |
| 11       | Repo separation                                           | After initial deployment works |
| 12       | iOS TestFlight pipeline                                   | Repo separation                |
| 13       | TapPay integration + lesson packages                      | Booking flow stable            |
| 14       | Future features                                           | Everything above               |


**Parallelization strategy**: Items 1-3 (backend schema + APIs) can run in parallel with Item 4 (admin UI redesign). Course drawing (7b, 7c) can run in parallel for web and mobile once the backend API (7) is done. Item 10 (deployment) can start anytime since the Dockerfile and Vite build already work.

---

## Technology Reference


| Technology            | Version  | Documentation                                                                             |
| --------------------- | -------- | ----------------------------------------------------------------------------------------- |
| Tailwind CSS          | v4       | `@import "tailwindcss"` in CSS, `@tailwindcss/vite` plugin, CSS-first config via `@theme` |
| TanStack Table        | v8       | `@tanstack/react-table` - headless, sorting/filtering/pagination                          |
| Recharts              | v2       | `ComposedChart`, `AreaChart` with gradients, `ResponsiveContainer`                        |
| tldraw                | v4.4     | Infinite canvas SDK for React - draw, export PNG/JSON, restore snapshots                  |
| flutter_drawing_board | latest   | Canvas drawing for Flutter - pen/shapes/eraser, undo/redo, PNG/JSON export                |
| Railway               | --       | Docker deploy from GitHub, MySQL add-on, env var references `${{MySQL.MYSQLHOST}}`        |
| Vercel                | Pro      | `vercel.json` with `rewrites` for SPA, auto-detect Vite framework                         |
| Fastlane              | >= 2.232 | `Fastfile` in `ios/`, `upload_to_testflight`, App Store Connect API key auth              |
| Flutter               | 3.24     | `flutter build ipa --release` for iOS, GitHub Actions on `macos-latest`                   |


---

## Appendix: Code Conventions (MUST follow during all implementation)

All new code must match the existing codebase patterns exactly -- as if the same developer wrote it. These conventions were documented from thorough study of every file in every layer.

### Backend Conventions

**File structure per feature:**

- `backend/models/{entity}.model.js` - Sequelize model
- `backend/services/{entity}.service.js` - business logic, DB queries
- `backend/controllers/{entity}.controller.js` - HTTP handler
- `backend/routes/{entity}.routes.js` - Express router

**Imports/Exports:**

- ES modules with `.js` extensions: `import { createHorse } from '../services/horse.service.js'`
- Named exports for services/controllers: `export const createHorse = async (...) => { ... }`
- Default export for router and models: `export default router`

**Controller pattern:**

- All handlers: `async (req, res) => { try { ... } catch (error) { handleError(res, error) } }`
- Shared `handleError` per controller: checks `error.message` for keywords (required/not found/access denied) -> 400, else 500
- Error response always: `{ message: string }` -- never `error`, `code`, or `details`
- File cleanup on error: `if (req.file) await deleteFileIfExists(req.file.path)`

**Service pattern:**

- Validation via `throw new Error('...')` (no Joi/express-validator)
- `normalizePagination({ page, limit })` and `buildPaginationMeta(...)` duplicated per service
- Response: `{ data: T[], pagination: { totalRecords, currentPage, nextPage, limit, totalPages, hasNext, hasPrev } }`
- Access control helpers: `ensureStableOwnedByAdmin`, `ensureDisciplineExists`
- Queries: `findByPk`, `findAndCountAll` with `offset`, `limit`, `distinct: true`, `subQuery: false`
- Search: `Op.like` + `%keyword%`, `Op.or` across fields including `'$association.field$'`

**Route pattern:** Public first, then auth+upload+handler. Order: `get /public` -> `post /` -> `get /` -> `get /:id` -> `put /:id` -> `delete /:id`

**Model pattern:** `sequelize.define('Name', { fields }, { tableName: 'snake_case', timestamps: false })`. Associations in `models/index.js`.

**Naming:** DB/API = `snake_case`, JS = `camelCase`, controllers = `{action}{Resource}Controller`, services = `{action}{Resource}`

### Frontend Admin Conventions

**Data fetching:** `useEffect` + `useState`, NOT Redux (Redux only for auth). `Promise.all` for multiple. Response normalized: `Array.isArray(data?.data) ? data.data : []`.

**Form state:** `emptyForm` constant -> `useState(emptyForm)` -> `setForm(prev => ({ ...prev, field: value }))`. `editingId` toggles create/edit.

**API layer** (`operationsApi.js`): Named `getXxxApi`/`createXxxApi`/`updateXxxApi`/`deleteXxxApi`. `buildListQuery(params)` for queries. `toFormData(payload, fieldName, file)` for uploads.

**Image uploads:** Validate -> `setCropSourceFile` -> `ImageCropperModal` -> `onApply` -> `setImageFile`. Preview via `URL.createObjectURL`.

**Tables:** Native `<table>`, `overflow-x-auto rounded-xl border`, `thead bg-gray-50 dark:bg-gray-800/60`, status badges `rounded-full px-2.5 py-1 text-xs font-medium`.

**Modals:** `<Modal isOpen title onClose>`, form inside, submit -> API -> toast -> close -> refetch.

**Styling:** Cards `rounded-2xl border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900`. Focus `focus:border-amber-500 focus:ring-2 focus:ring-amber-500/30`. Amber primary, gray secondary.

**Imports order:** React hooks -> third-party -> lucide icons -> local components -> API/features -> lib/hooks.

**Toasts:** `toast.success('Created.')` and `toast.error(error.message || 'Fallback.')` via `react-hot-toast`.

### Mobile App (Flutter) Conventions

**Services:** Singleton `ApiService()`, instance methods `get`/`post`/`put`/`patch`/`delete`. Domain services hold `final ApiService _api = ApiService()`. Return `Map<String, dynamic>` or `List<dynamic>`. Handle both `Map`+key and raw `List` responses.

**Screens:** `StatefulWidget` when local state needed. `initState` -> `_loadData()`. `if (mounted) setState(...)`. `AppScaffold(appBar: null, body: ..., bottomNavigationBar: ...)`.

**Providers:** `ChangeNotifier` with private state, public getter, `notifyListeners()` on every setter.

**Navigation:** `Navigator.push` with `MaterialPageRoute`, `pushAndRemoveUntil` for auth, `SmoothPageRoute` for custom transitions.

**Theme:** `AppColors.primary`, `AppTextStyles.h1.copyWith(...)`, `AppSpacing.lg`, `AppRadii.lg`. Fonts: Libre Baskerville headings, Plus Jakarta Sans body.

**Naming:** Files `snake_case.dart`, classes `PascalCase`, private state `_camelCase`, methods `camelCase`.

**Error handling:** `if (mounted)` before `setState`, `.catchError((_) => <dynamic>[])` for list fallbacks, `AuthService.getErrorMessage(error)` for user-facing messages.