# Git repo hooks for various things (Spidey and LISA)

## pre-commit

This checks all ruby code staged for commit with `ruby -c` for syntax errors, and will fail the commit if it finds any.

## prepare-commit-msg

This is a git-hook that adds your active JIRA issues to the blank commit message, when you make a commit. Your editor will have something like the following when you commit:

```
# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
# On branch master
# Your branch and 'origin/master' have diverged,
# and have 2 and 4 different commit(s) each, respectively.
#
#
# Below are your active JIRA Issues (uncomment one or more to attach this commit to it):
# ------------------------------------------------------------------
#[LFEDM-26] - NW - Bills Update date issue
#[LFEDM-133] - NW - Last Update should include what changed
#[LFEDM-135] - NW need list of events/fields that are updated in LISA
#[LFEDM-181] - UI - enable jump to state feature for search
#[LFEDM-186] - NW - bouce back email
#[LFEDM-191] - Dashboard Cells Picking up Colors Inconsistently
#[LFEDM-197] - Database - need seond web box
#[LFEDM-198] - NW - View in Browser
#[LFEDM-199] - NW - Integrate Search Query Groups
#[LFEDM-204] - Add Search Query Grouping feature
#[SUPRT-43] - Admin - create 3 menu options for custom content
#[SUPRT-64] - Map Select Links not updating
#
#
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#       modified:   app/models/state.rb
#       new file:   app/observers/state_link_observer.rb
#       modified:   config/application.rb
#       modified:   config/environments/development.rb
#
```

This allows for an easy way to attach JIRA issue IDs to commits, so that the JIRA DCVS plugin can attach those commits to the issues themselves.

## commit-msg

This ensures that your commit message includes a JIRA issue ID, and won't let you commit without it.

## Installation

To get this set up, you need to set up your LISA/Spidey local git repository hooks folder to be a checkout of this repo. Do this within the Rails root:

```
% cd .git/
% rm hooks/*.sample
% rmdir hooks # if this fails, you have some hooks already and you should deal with that
% git clone git@github.com:lisausa/git-hooks.git hooks
```

Then set up your JIRA credantials:
```
% git config jira.username '<username>' # these are your JIRA log in credentials
% git config jira.password '<password>'
```

Now when you attempt a commit, it will pull down a list of all issues currently assigned to you and in one of the following states:

- Open
- In Progress
- Reopened
- Building
- Testing - QA

See line 12 of the hook (`query = ...`) to change the criteria. The query must be valid [JQL](https://confluence.atlassian.com/display/JIRA/Advanced+Searching)
