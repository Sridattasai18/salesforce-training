# Salesforce Source-Driven Deployment Workflow

This document describes the complete workflow for cloning, authenticating, retrieving, deploying, testing and verifying the Placement Management System — the workflow performed during Day 12.

---

## Prerequisites

| Tool | Install | Verify |
|---|---|---|
| Git | https://git-scm.com | `git --version` |
| Salesforce CLI | https://developer.salesforce.com/tools/salesforcecli | `sf --version` |
| Salesforce Developer Org | https://developer.salesforce.com/signup | login via CLI |

Minimum Salesforce CLI version: `2.x` (uses `sf` commands, not deprecated `sfdx`).

---

## 1. Clone the Repository

```bash
git clone https://github.com/Sridattasai18/Placement-Management-System.git
cd Placement-Management-System
```

Verify structure:
```bash
ls
# Expected: force-app/  docs/  README.md  sfdx-project.json  .forceignore  .gitignore
```

---

## 2. Authenticate Your Salesforce Org

```bash
sf org login web --alias placement-dev --set-default
```

This opens a browser. Log in to your Developer Org. After success, the CLI stores the session locally (never in the repository).

Verify authentication:
```bash
sf org list
# Your org should appear with Status: Connected
```

Check org details:
```bash
sf org display --target-org placement-dev
# Shows: Username, Instance URL, Connected Status, Org ID
```

---

## 3. Configure the Named Credential (Required — Manual Step)

The source includes the Named Credential structure (`Recruitment_API.namedCredential-meta.xml`) but the endpoint URL is org-specific configuration, not stored in source.

After deployment, configure it manually:

1. In your org: **Setup → Named Credentials → `Recruitment API`**
2. Verify `Endpoint` is set to your external API URL
   - Demo/test value: `https://jsonplaceholder.typicode.com`
   - Production value: replace with your actual recruitment API
3. `Principal Type`: Anonymous (for demo); update to OAuth or Password for real environments
4. Save

> Never commit credentials, tokens, or passwords to source control.

---

## 4. Deploy All Metadata

Deploy the entire source to your authenticated org:

```bash
sf project deploy start --target-org placement-dev
```

Expected output:
```
Status: Succeeded
Components: X/X (100%)
```

Deploy with test validation (recommended before production):
```bash
sf project deploy start --test-level RunLocalTests --target-org placement-dev
```

Deploy specific layers if needed:
```bash
# Objects and fields only
sf project deploy start --source-dir force-app/main/default/objects --target-org placement-dev

# Apex classes and triggers only
sf project deploy start --source-dir force-app/main/default/classes --target-org placement-dev
sf project deploy start --source-dir force-app/main/default/triggers --target-org placement-dev

# LWC only
sf project deploy start --source-dir force-app/main/default/lwc --target-org placement-dev

# Named Credential
sf project deploy start --source-dir force-app/main/default/namedCredentials --target-org placement-dev
```

---

## 5. Retrieve Metadata from Org

To pull the latest org state back into source (e.g. after declarative changes in Setup):

```bash
sf project retrieve start --target-org placement-dev
```

Retrieve specific components:
```bash
sf project retrieve start \
  --metadata "CustomObject:Student__c" \
  --metadata "CustomObject:Job__c" \
  --metadata "CustomObject:Application__c" \
  --metadata "CustomObject:Integration_Log__c" \
  --metadata "ApexClass:StudentPortalController" \
  --metadata "ApexTrigger:ApplicationTrigger" \
  --target-org placement-dev
```

After retrieval, always inspect the diff before committing:
```bash
git diff --stat
git diff
```

Only commit changes that are expected and understood.

---

## 6. Run Apex Tests

Run all local tests:
```bash
sf apex run test --test-level RunLocalTests --result-format human --target-org placement-dev
```

Run specific Day 11 integration tests:
```bash
sf apex run test --class-names ExternalPlacementServiceTest --result-format human --target-org placement-dev
```

Expected results:
```
Tests Ran:    6
Pass Rate:    100%
Outcome:      Passed
```

All 6 `ExternalPlacementServiceTest` tests cover:
- Successful HTTP callout → Integration_Log__c created with `Success__c = true`
- API 500 failure → logged with `Success__c = false`
- Empty input → no log created
- Queueable job execution
- Trigger fires on `Selected` status → end-to-end chain verified
- Trigger does NOT fire on `Rejected` status

---

## 7. Verify Deployment in the Org

After deployment, verify the key components:

**Objects and Fields:**
- Setup → Object Manager → `Student__c`, `Job__c`, `Application__c`, `Integration_Log__c`
- Confirm all custom fields are present

**Apex Classes:**
- Setup → Apex Classes → confirm 20 classes deployed and Active

**Apex Triggers:**
- Setup → Apex Triggers → confirm `ApplicationTrigger`, `StudentTrigger`, `JobTrigger` Active

**LWC Components:**
- Setup → Lightning Components → confirm 9 components deployed

**Named Credential:**
- Setup → Named Credentials → `Recruitment API` — confirm present and configured

**Flows (configured in org, not in source):**
- Setup → Flows → verify `Set Application Date` and `Create Offer Letter` flows are Active

---

## 8. Add LWC to Lightning App Page (Manual — One-time)

LWC components are deployed to the org but must be manually placed on a Lightning App Page:

1. Setup → Lightning App Builder → New (or edit existing)
2. Type: App Page, name: `Placement Portal`
3. Drag `studentPortal` component onto the page
4. Save → Activate → assign to relevant app

For the dashboard:
1. Create or edit another page
2. Drag `placementDashboard` component
3. Save → Activate

---

## 9. Branching Strategy

```
main
  └── feature/<description>   ← all new work happens here
        └── commit
        └── push
        └── Pull Request → reviewed → merged to main
              └── deploy from main to org
```

**Rules:**
- Never commit directly to `main`
- One feature per branch
- Branch names: `feature/`, `fix/`, `docs/`
- Merge only after review

**Create a feature branch:**
```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature-name
```

**Push and open a PR:**
```bash
git push -u origin feature/your-feature-name
# Then open Pull Request on GitHub
```

**After PR is merged:**
```bash
git checkout main
git pull origin main
sf project deploy start --target-org placement-dev
```

---

## 10. Troubleshooting

### Authentication failure
```
Error: No org found / No authorization information found
```
**Fix:**
```bash
sf org list           # check what orgs are authenticated
sf org login web --alias placement-dev --set-default
```

### Deployment failure: missing dependency
```
Error: Component failures — field/object not found
```
**Fix:** Deploy objects before classes:
```bash
sf project deploy start --source-dir force-app/main/default/objects --target-org placement-dev
sf project deploy start --source-dir force-app/main/default/classes --target-org placement-dev
```

### Apex test failure
```
Error: FIELD_INTEGRITY_EXCEPTION / required field missing
```
**Fix:** Check test data setup in the test class. Ensure all required fields (e.g. `Roll_Number__c`, `Active_Backlogs__c`, `Placement_Status__c`) are populated in `@IsTest` data factory methods.

### Named Credential callout error
```
Error: Unauthorized endpoint — callout:Recruitment_API not found
```
**Fix:**
1. Deploy the Named Credential: `sf project deploy start --source-dir force-app/main/default/namedCredentials`
2. Verify in Setup → Named Credentials → `Recruitment API` is present
3. Confirm the endpoint URL is configured

### Git conflict on merge
When two branches modify the same file, Git cannot auto-merge:
```
<<<<<<< HEAD
// your change
=======
// incoming change
>>>>>>> feature/other-branch
```
**Fix:**
1. Open the file in VS Code
2. Read both versions — understand the intended behaviour of each
3. Edit the file to contain the correct final version
4. Remove all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
5. Stage and commit:
```bash
git add <file>
git commit -m "fix: resolve merge conflict in <file>"
```
Never blindly accept one side without understanding both changes.

### LWC component not appearing in App Builder
**Fix:**
1. Check `isExposed: true` in the component's `.js-meta.xml`
2. Verify the correct `<target>` is declared (e.g. `lightning__AppPage`)
3. Redeploy: `sf project deploy start --source-dir force-app/main/default/lwc`
4. Hard refresh Lightning App Builder (Ctrl+Shift+R)

---

## 11. Source-Controlled vs Org-Specific Configuration

### Source-Controlled (in this repository)

| Metadata | Location |
|---|---|
| Apex classes | `force-app/main/default/classes/` |
| Apex triggers | `force-app/main/default/triggers/` |
| LWC components | `force-app/main/default/lwc/` |
| Custom objects | `force-app/main/default/objects/` |
| Custom fields | `force-app/main/default/objects/*/fields/` |
| Validation rules | `force-app/main/default/objects/*/validationRules/` |
| List views | `force-app/main/default/objects/*/listViews/` |
| Named Credential structure | `force-app/main/default/namedCredentials/` |

### Org-Specific Configuration (manual — NOT in source)

| Configuration | Why not in source |
|---|---|
| Named Credential endpoint URL | Environment-specific — different per org |
| Named Credential authentication secrets | Never stored in source control |
| Lightning App Page layout | Manually configured per org |
| Org-wide email settings | Org-specific |
| Users and profiles | Org-specific |
| Scheduled job instances | Runtime state, not metadata |
| Debug log settings | Local development only |

---

## 12. Salesforce Environment Concepts

### What We Actually Used

| Tool | Usage |
|---|---|
| Git | Version control, branching, history |
| GitHub | Remote repository, Pull Requests, code review |
| Salesforce CLI (`sf`) | Authentication, deploy, retrieve, test |
| Developer Edition Org | Target Salesforce environment |
| Source-driven development | Source of truth is the repository, not the org |

### What We Learned Conceptually

**Sandbox**
A copy of a production org used for testing before deploying to production. Developer Sandbox, Partial Copy Sandbox, Full Copy Sandbox — each with different data and refresh limits. We used a Developer Edition org, which serves the same purpose for this project.

**Scratch Org**
A temporary, disposable Salesforce environment. Created from source, lives for up to 30 days, used in modern DX workflows and CI/CD pipelines. Requires a Dev Hub org. Not used in this project but the correct next step for automated pipeline work.

**Change Sets**
A declarative, point-and-click deployment method. Packages metadata in the org UI and deploys to connected orgs. Does not require CLI or Git. Less reliable for complex projects — no version history, no code review, no automated testing. We used CLI source-driven deployment instead.

**Metadata API**
The underlying Salesforce API that CLI and Change Sets use. Directly accessible for advanced use cases but CLI commands are the recommended developer interface.

---

## 13. Complete Day 12 Workflow Reference

```
git clone https://github.com/Sridattasai18/Placement-Management-System.git
cd Placement-Management-System

sf org login web --alias placement-dev --set-default
sf org list

sf project deploy start --target-org placement-dev

# Configure Named Credential manually in org UI

sf apex run test --test-level RunLocalTests --result-format human --target-org placement-dev

git checkout -b feature/your-change
# make changes
git add .
git commit -m "type: description"
git push -u origin feature/your-change

# Open Pull Request on GitHub → review → merge

git checkout main
git pull origin main
sf project deploy start --target-org placement-dev
sf apex run test --test-level RunLocalTests --result-format human --target-org placement-dev
```

---

*Last updated: Day 12 — Source-Driven Deployment Workflow*
