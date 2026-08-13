# Salesforce Development Workflow Guide

This document outlines the complete workflow for working with this Salesforce project — from setup to deployment to Git management.

---

## Table of Contents

1. [Initial Project Setup](#initial-project-setup)
2. [Project Structure](#project-structure)
3. [Org Authentication](#org-authentication)
4. [Development Workflow](#development-workflow)
5. [Deployment Commands](#deployment-commands)
6. [Git Workflow](#git-workflow)
7. [Common Issues & Solutions](#common-issues--solutions)
8. [Quick Reference](#quick-reference)

---

## Initial Project Setup

### Creating a New Salesforce Project

```bash
# Create a new SFDX project
sf project generate --name my-project

# Navigate into the project
cd my-project
```

### Cloning an Existing Project

```bash
# Clone the repository
git clone <repository-url>
cd salesforce-training

# Verify project structure
dir
```

---

## Project Structure

```
salesforce-training/
├── force-app/                          # Main source directory (deployed to Salesforce)
│   └── main/
│       └── default/
│           ├── classes/                # Apex classes
│           │   ├── ApplicationService.cls
│           │   ├── ApplicationService.cls-meta.xml
│           │   ├── ApplicationTriggerHandler.cls
│           │   └── ...
│           ├── triggers/               # Apex triggers
│           │   ├── ApplicationTrigger.trigger
│           │   └── ApplicationTrigger.trigger-meta.xml
│           ├── lwc/                    # Lightning Web Components
│           ├── objects/                # Custom objects and fields
│           └── ...
├── Bridge-Program/                     # Learning materials (NOT deployed)
│   ├── Day-01/
│   ├── Day-02/
│   └── ...
├── .git/                               # Git version control
├── .sfdx/                              # SFDX local config
├── .sf/                                # SF CLI local config
├── sfdx-project.json                   # Project configuration
└── README.md                           # Project documentation
```

**Key Points:**
- Only `force-app/` content is deployed to Salesforce
- `Bridge-Program/` is for notes, examples, and reference code
- `.sfdx/` and `.sf/` contain local CLI settings (not pushed to Git)

---

## Org Authentication

### Connecting to Your Salesforce Org

```bash
# Authenticate with a scratch org or sandbox
sf org login web

# Authenticate with production (use carefully)
sf org login web --instance-url https://login.salesforce.com

# Set a default org
sf config set target-org <username>
```

### Checking Connection Status

```bash
# List all authenticated orgs
sf org list

# Display current org info
sf org display

# Check which org is set as default
sf config get target-org
```

### Opening Your Org

```bash
# Open the org in a browser
sf org open
```

---

## Development Workflow

### Step 1: Create/Modify Code

Work in the `force-app/` directory:

```
force-app/main/default/classes/MyClass.cls          # Your Apex code
force-app/main/default/classes/MyClass.cls-meta.xml # Metadata file (required)
```

**Every Apex class needs a metadata file:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>59.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

### Step 2: Deploy to Org

```bash
# Deploy everything in force-app/
sf project deploy start

# Deploy specific files (faster)
sf project deploy start --source-dir force-app/main/default/classes/MyClass.cls

# Deploy and validate without saving (dry run)
sf project deploy start --dry-run

# Deploy with tests
sf project deploy start --test-level RunLocalTests
```

### Step 3: Test in Salesforce

1. Open your org: `sf org open`
2. Navigate to relevant objects/pages
3. Test functionality manually
4. Check logs: Setup → Debug Logs

### Step 4: Verify with SOQL (if needed)

```bash
# Run SOQL query from terminal
sf data query --query "SELECT Id, Name FROM Account LIMIT 5"
```

Or use Developer Console → Query Editor in the org.

---

## Deployment Commands

### Basic Deployment

```bash
# Deploy all metadata
sf project deploy start

# Deploy and see what's being deployed
sf project deploy start --verbose
```

### Targeted Deployment

```bash
# Deploy a single class
sf project deploy start --source-dir force-app/main/default/classes/ApplicationService.cls

# Deploy multiple specific files
sf project deploy start --source-dir force-app/main/default/classes,force-app/main/default/triggers

# Deploy an entire folder
sf project deploy start --source-dir force-app/main/default/lwc
```

### Deployment with Tests

```bash
# Run local tests (all tests in your org)
sf project deploy start --test-level RunLocalTests

# Run specific tests
sf project deploy start --test-level RunSpecifiedTests --tests MyTestClass,AnotherTestClass

# Skip tests (only works in sandbox, not production)
sf project deploy start --test-level NoTestRun
```

### Check Deployment Status

```bash
# View status of last deployment
sf project deploy report

# View status by job ID
sf project deploy report --job-id 0Af...
```

### Retrieve Metadata from Org

```bash
# Pull changes from org to local
sf project retrieve start

# Retrieve specific components
sf project retrieve start --metadata ApexClass:MyClass
```

---

## Git Workflow

### Initial Setup (First Time Only)

```bash
# Initialize Git (if not already done)
git init

# Configure your identity
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add remote repository
git remote add origin https://github.com/username/repo.git
```

### Daily Workflow

#### 1. Check Status

```bash
# See what files have changed
git status

# See detailed changes
git diff
```

#### 2. Stage Changes

```bash
# Stage specific files
git add force-app/main/default/classes/ApplicationService.cls

# Stage all changed files
git add .

# Stage all files in a directory
git add force-app/main/default/classes/

# Interactive staging (choose what to stage)
git add -p
```

#### 3. Commit Changes

```bash
# Commit with a message
git commit -m "Day 2: Added ApplicationService and trigger handler"

# Commit with a detailed message (opens editor)
git commit

# Amend the last commit (if you forgot something)
git commit --amend
```

**Good Commit Message Format:**
```
Day X: Brief summary (50 chars or less)

- Detailed point 1
- Detailed point 2
- What was tested

Relates to: #issue-number
```

#### 4. Push to Remote

```bash
# Push to main branch
git push origin main

# Push to a new branch (first time)
git push -u origin feature-branch-name

# Push after setting upstream
git push
```

### Branch Management

```bash
# Create a new branch
git branch day-02-work

# Switch to a branch
git checkout day-02-work

# Create and switch in one command
git checkout -b day-02-work

# List all branches
git branch -a

# Merge a branch into main
git checkout main
git merge day-02-work

# Delete a branch (after merging)
git branch -d day-02-work
```

### Viewing History

```bash
# View commit history
git log

# View compact history
git log --oneline

# View history with graph
git log --graph --oneline --all

# View changes in a specific commit
git show <commit-hash>
```

### Undoing Changes

```bash
# Discard changes in a file (before staging)
git checkout -- filename

# Unstage a file (keep changes)
git reset HEAD filename

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes) ⚠️ DESTRUCTIVE
git reset --hard HEAD~1

# Revert a commit (creates new commit)
git revert <commit-hash>
```

### Syncing with Remote

```bash
# Fetch changes from remote
git fetch origin

# Pull changes from remote (fetch + merge)
git pull origin main

# Pull with rebase (cleaner history)
git pull --rebase origin main
```

---

## Common Issues & Solutions

### Issue: "Invalid type: ApplicationService.ApplicationException"

**Cause:** Missing method or inner class in service layer.

**Solution:**
1. Check what the controller/LWC is calling
2. Add the missing method to ApplicationService
3. Redeploy

```bash
sf project deploy start --source-dir force-app/main/default/classes/ApplicationService.cls
```

### Issue: "GLIBC_2.28 not found" or similar OS errors

**Cause:** Old `sfdx` CLI vs new `sf` CLI mismatch.

**Solution:** Use `sf` commands consistently:
```bash
# Old (deprecated)
sfdx force:source:deploy

# New (use this)
sf project deploy start
```

### Issue: Merge Conflicts in Git

**Cause:** Same file edited in two different branches.

**Solution:**
1. `git status` to see conflicted files
2. Open the file, look for `<<<<<<<`, `=======`, `>>>>>>>` markers
3. Manually resolve conflicts
4. Stage the resolved file: `git add filename`
5. Complete the merge: `git commit`

### Issue: "No org found"

**Cause:** Not authenticated or no default org set.

**Solution:**
```bash
# List orgs
sf org list

# Set default
sf config set target-org username@example.com

# Or authenticate again
sf org login web
```

---

## Quick Reference

### Most Used Commands

```bash
# Deploy everything
sf project deploy start

# Deploy one file
sf project deploy start --source-dir force-app/main/default/classes/MyClass.cls

# Check org connection
sf org display

# Open org
sf org open

# Git: Stage, commit, push
git add .
git commit -m "Message"
git push

# Git: Check status
git status

# Git: View history
git log --oneline
```

### Typical Day 2 Workflow

```bash
# 1. Make code changes in force-app/

# 2. Deploy
sf project deploy start

# 3. Test in org
sf org open

# 4. Commit to Git
git add force-app/
git commit -m "Day 2: Trigger handler architecture"
git push origin main
```

### File Naming Conventions

| Type | File Extension | Metadata File |
|------|---------------|---------------|
| Apex Class | `.cls` | `.cls-meta.xml` |
| Apex Trigger | `.trigger` | `.trigger-meta.xml` |
| LWC | `.js`, `.html`, `.css` | `.js-meta.xml` |
| Custom Object | `.object-meta.xml` | N/A |
| Custom Field | `.field-meta.xml` | N/A |

---

## Notes

- **Always test in a sandbox first** before deploying to production
- **Deploy often** — small, frequent deployments are easier to debug
- **Commit frequently** — makes it easier to undo mistakes
- **Write clear commit messages** — helps you and others understand what changed
- **Use branches for experiments** — keeps main branch stable
- **Never commit `.sfdx/` or `.sf/` directories** — they're local config only
- **Always include metadata files** — Apex classes need `.cls-meta.xml`, triggers need `.trigger-meta.xml`, etc.

---

## Additional Resources

- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [Git Documentation](https://git-scm.com/doc)
- [Salesforce Metadata API Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/)

---

**Last Updated:** Day 2 of Bridge Program
