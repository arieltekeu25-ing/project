# Visit Request System Implementation Documentation

## Overview
This document describes the implementation of the visit request system for the GestBailleur application. The system allows authenticated clients to request visits for published properties, and landlords to manage these requests (accept, reject, reschedule).

## Architecture
- **Backend**: Django REST Framework with PostgreSQL
- **Frontend**: Flutter with Riverpod state management
- **Communication**: REST API with JWT authentication

## Backend Implementation

### Django Model
**File**: `gestionbailleur-backend/visits/models/visit.py`

The `Visit` model includes:
- `property`: ForeignKey to Property
- `client`: ForeignKey to CustomUser (requester)
- `landlord`: ForeignKey to CustomUser (property owner)
- `requested_date`: Date field for visit
- `requested_time`: Time field for visit
- `message`: Optional message from client
- `status`: Choice field (PENDING, ACCEPTED, REJECTED, RESCHEDULED, CANCELLED, COMPLETED)
- `landlord_response`: Optional response from landlord
- `rescheduled_date`: Optional new date for rescheduling
- `rescheduled_time`: Optional new time for rescheduling
- `rescheduled_message`: Optional message for rescheduling

**Constraints**:
- Unique constraint on property, client, requested_date, requested_time for PENDING visits
- Indexes on property, client, landlord, status, requested_date

### Django Serializers
**File**: `gestionbailleur-backend/visits/serializers/visit.py`

Three serializers:
1. **VisitSerializer**: Full serialization with embedded property/client/landlord data
2. **VisitCreateSerializer**: For creating visits with validation
3. **VisitUpdateSerializer**: For updating visits (accept, reject, reschedule)

**Validation**:
- Property must be PUBLISHED
- Date cannot be in the past
- No duplicate pending visits for same property/client/date/time
- Rescheduling requires both date and time

### Django Views
**File**: `gestionbailleur-backend/visits/views/visit.py`

API Endpoints:
- `GET /api/v1/visits/my/`: List client's visit requests
- `GET /api/v1/visits/landlord/`: List landlord's received visit requests
- `GET /api/v1/visits/<id>/`: Get visit details
- `POST /api/v1/visits/create/`: Create visit request
- `PUT/PATCH /api/v1/visits/<id>/update/`: Update visit (landlord actions)
- `POST /api/v1/visits/<id>/cancel/`: Cancel visit (client action)
- `POST /api/v1/visits/<id>/accept-reschedule/`: Accept reschedule (client action)

**Permissions**:
- All endpoints require authentication
- Client can only access their own visits
- Landlord can only access visits for their properties
- Only landlord can update visit status
- Only client can cancel their own visits

### Notifications
Integrated with existing Notification system:
- **VISIT_REQUEST**: Sent to landlord when client requests visit
- **VISIT_ACCEPTED**: Sent to client when landlord accepts
- **VISIT_REJECTED**: Sent to client when landlord rejects
- **VISIT_RESCHEDULED**: Sent to client when landlord proposes new date
- **VISIT_RESCHEDULE_ACCEPTED**: Sent to landlord when client accepts new date
- **VISIT_CANCELLED**: Sent to landlord when client cancels

### Database Migration
- Created migration: `visits/migrations/0001_initial.py`
- Applied successfully to database

## Frontend Implementation

### Domain Model
**File**: `gestionbailleur/lib/features/domain/models/visite.dart`

Updated `Visite` model to match backend:
- Fields aligned with Django model
- Added embedded data fields (propertyTitle, propertyAddress, etc.)
- Added `VisitStatus` enum for type-safe status handling
- `fromMap` and `toMap` methods for serialization

### API Endpoints
**File**: `gestionbailleur/lib/core/network/api_endpoints.dart`

Added visit endpoints:
- `myVisits`: `/api/v1/visits/my/`
- `landlordVisits`: `/api/v1/visits/landlord/`
- `visitDetail(id)`: `/api/v1/visits/{id}/`
- `createVisit`: `/api/v1/visits/create/`
- `visitUpdate(id)`: `/api/v1/visits/{id}/update/`
- `visitCancel(id)`: `/api/v1/visits/{id}/cancel/`
- `visitAcceptReschedule(id)`: `/api/v1/visits/{id}/accept-reschedule/`

### Repository
**File**: `gestionbailleur/lib/features/property/repositories/visit_repository.dart`

Methods:
- `getMyVisits()`: Fetch client's visits
- `getLandlordVisits()`: Fetch landlord's received visits
- `getVisitDetail(visitId)`: Fetch specific visit
- `createVisit(...)`: Create new visit request
- `updateVisit(...)`: Update visit status/reschedule
- `cancelVisit(visitId)`: Cancel visit
- `acceptReschedule(visitId)`: Accept reschedule proposal

### State Management
**File**: `gestionbailleur/lib/features/property/providers/visit_provider.dart`

Riverpod StateNotifier:
- `VisitState`: Holds myVisits, landlordVisits, selectedVisit, loading states
- `VisitNotifier`: Methods for all visit operations
- `visitProvider`: StateNotifierProvider for consumption

### UI Components

#### Visit Request Dialog
**File**: `gestionbailleur/lib/features/property/widgets/visit_request_dialog.dart`

Features:
- Date picker (no past dates)
- Time picker (24-hour format)
- Optional message field
- Form validation
- Loading state during submission
- Success/error feedback

#### Client Visit Requests Page
**File**: `gestionbailleur/lib/features/property/pages/visit_requests_page.dart`

Features:
- List of client's visit requests
- Status badges with colors
- Property details preview
- Visit details dialog
- Cancel button for PENDING/RESCHEDULED visits
- Refresh on pull
- Empty state handling

#### Landlord Visit Requests Page
**File**: `gestionbailleur/lib/features/property/pages/landlord_visit_requests_page.dart`

Features:
- List of landlord's received visit requests
- Client information display
- Property details preview
- Accept/Reject/Reschedule actions for PENDING visits
- Action dialogs with forms
- Refresh on pull
- Empty state handling

### Navigation

#### Router Configuration
**File**: `gestionbailleur/lib/core/router/app_router.dart`

Added routes:
- `/visits/my`: VisitRequestsPage (client)
- `/visits/landlord`: LandlordVisitRequestsPage (landlord)

#### Dashboard Integration

**Client Dashboard** (`client_dashboard_page.dart`):
- Added "Mes demandes de visite" button

**Landlord Dashboard** (`landlord_dashboard_page.dart`):
- Added "Demandes de visite" button

#### Property Details Page
**File**: `gestionbailleur/lib/features/property/pages/property_details_page.dart`

Modified `_showVisitDialog`:
- Check authentication
- Check if user is property owner
- Check property availability
- Show VisitRequestDialog for valid requests

## Status Flow

```
PENDING → ACCEPTED (landlord accepts)
PENDING → REJECTED (landlord rejects)
PENDING → RESCHEDULED (landlord proposes new date)
PENDING → CANCELLED (client cancels)

RESCHEDULED → ACCEPTED (client accepts new date)
RESCHEDULED → CANCELLED (client cancels)

ACCEPTED → COMPLETED (manual completion, not implemented in UI)
```

## Security Considerations

1. **Authentication**: All endpoints require JWT authentication
2. **Authorization**: 
   - Clients can only access their own visits
   - Landlords can only access visits for their properties
3. **Validation**: Backend validates all inputs
4. **Ownership**: Backend enforces ownership constraints
5. **Status Transitions**: Backend controls valid status transitions

## Testing

### Build Test
- Flutter web build: **SUCCESS**
- No compilation errors
- WebAssembly warnings (informational, related to flutter_secure_storage_web)

### Manual Testing Required
1. Client creates visit request on published property
2. Landlord receives notification
3. Landlord accepts/rejects/reschedules
4. Client receives notification
5. Client cancels visit
6. Client accepts reschedule
7. Verify all status_transitions
8. Test error handling (network errors, validation errors)

## Files Created/Modified

### Backend
- `visits/models/visit.py` (created)
- `visits/models/__init__.py` (modified)
- `visits/serializers/visit.py` (created)
- `visits/serializers/__init__.py` (modified)
- `visits/views/visit.py` (created)
- `visits/views/__init__.py` (modified)
- `visits/urls/__init__.py` (modified)
- `visits/apps.py` (modified - app name fix)
- `config/settings/base.py` (modified - added visits app)
- `config/api_urls.py` (modified - added visits URLs)

### Frontend
- `lib/features/domain/models/visite.dart` (modified - updated model)
- `lib/core/network/api_endpoints.dart` (modified - added visit endpoints)
- `lib/features/property/repositories/visit_repository.dart` (created)
- `lib/features/property/providers/visit_provider.dart` (created)
- `lib/features/property/widgets/visit_request_dialog.dart` (created)
- `lib/features/property/pages/visit_requests_page.dart` (created)
- `lib/features/property/pages/landlord_visit_requests_page.dart` (created)
- `lib/features/property/pages/property_details_page.dart` (modified - visit dialog integration)
- `lib/core/router/app_router.dart` (modified - added routes)
- `lib/features/client/pages/client_dashboard_page.dart` (modified - added button)
- `lib/features/landlord/pages/landlord_dashboard_page.dart` (modified - added button)

## Limitations & Future Enhancements

### Current Limitations
1. No real-time updates (polling required)
2. No in-app notification display (backend creates notifications but UI doesn't show them)
3. No "COMPLETED" status transition in UI
4. No visit history filtering
5. No bulk actions for landlords

### Future Enhancements
1. WebSocket integration for real-time updates
2. In-app notification display
3. Visit completion workflow
4. Calendar view for visits
5. Visit reminder notifications
6. Visit feedback/rating system
7. Analytics dashboard for visit statistics

## API Documentation

All visit endpoints are documented with drf-spectacular and available at:
- Swagger UI: `/api/docs/`
- ReDoc: `/api/redoc/`
- Schema: `/api/schema/`

## Conclusion

The visit request system has been successfully implemented with:
- Full backend API with validation and security
- Complete frontend UI with state management
- Notification integration
- Proper error handling
- Clean architecture following existing patterns

The system is ready for testing and deployment.
