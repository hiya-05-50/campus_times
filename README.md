# Campus Times

Campus Times is an integrated campus management and placement platform.

## Placements Module (Aditya)

The Placements module manages campus recruitment drives, student eligibility calculation, job applications, application withdrawal, and administrative candidate review.

### Features

- **Open Placement Drives**: Students can view active, upcoming, and closed recruitment drives with company overview, role description, CTC/stipend packages, and deadlines.
- **Automated Eligibility Engine (`PlacementEligibilityChecker`)**:
  - Evaluates student qualifications across five criteria:
    1. **Minimum CGPA** (student CGPA vs. required minimum)
    2. **Active Backlogs** (student backlog count vs. maximum allowable backlogs)
    3. **Department Eligibility** (student department against approved departments or all-department open status)
    4. **Graduation Year** (student graduation year against target batch year)
    5. **Application Deadline** (current timestamp vs. drive deadline)
  - Produces detailed passed and failed explanations for each criterion.
- **Duplicate & Ineligibility Protection**: Ineligible students and students who have already applied are prevented from submitting duplicate or invalid applications at both the service/model validation layer and database constraint layer (unique compound indexes).
- **Application Withdrawal**: Students can withdraw their active applications prior to drive closure. Students are restricted from withdrawing another candidate's application.
- **Administrative Inspection & Status Management**: Admins can view applicant breakdowns, inspect individual eligibility metrics, and transition application statuses (`applied`, `shortlisted`, `interviewed`, `selected`, `rejected`, `withdrawn`).

### Key Models & Services

- `Company`: Registered recruiting employers and contact profiles.
- `PlacementDrive`: Job drives with compensation, eligibility thresholds, and deadlines.
- `PlacementDriveDepartment`: Join model mapping drives to eligible academic departments.
- `PlacementApplication`: Student applications with status tracking, withdrawal timestamps, and uniqueness constraints.
- `PlacementEligibilityChecker`: Service object evaluating all recruitment criteria and generating explanations.
- `Department` & `User`: Academic departments and user accounts with role-based scoping (`student`, `faculty`, `admin`).

### Routes & Endpoints

- `GET /placements` (`placement_drives#index`): Browse open and filtered placement drives.
- `GET /placements/:id` (`placement_drives#show`): View drive details, automated eligibility checklist, and applicant review (admin).
- `POST /placements/:id/applications` (`placement_applications#create`): Submit student application.
- `GET /placement_applications` (`placement_applications#index`): View student applications or admin inspection list.
- `PATCH /placement_applications/:id/withdraw` (`placement_applications#withdraw`): Withdraw an existing application.
- `PATCH /placement_applications/:id` (`placement_applications#update`): Update applicant status (admin).
- `resources :companies`: CRUD for employer partner profiles.

### Demo & Seed Data

Seed data is available in `db/seeds/placements.rb` containing demo companies, departments, students of varying eligibility criteria (eligible, low CGPA, active backlogs, wrong department, wrong graduation batch), open drives, and closed drives.

To load the seed data:
```bash
bin/rails runner db/seeds/placements.rb
```

### Verification Commands

Every teammate should run:
```bash
bin/rails db:migrate
bin/rails test
bin/rails zeitwerk:check
bin/rubocop
bin/brakeman --no-pager
```

### Shared File Integration Notes (For Integrator)

- **Routes**: Added `resources :companies`, `resources :placement_drives, path: "placements"`, and `resources :placement_applications` to `config/routes.rb`.
- **Inflections**: Added `irregular "placement_drive", "placement_drives"` and `irregular "drive", "drives"` to `config/initializers/inflections.rb`.
- **Stylesheets**: Placement styles are modularized in `app/assets/stylesheets/placements.css` without modifying `application.css`.
- **Seeds**: Placement demo data is isolated in `db/seeds/placements.rb`.
