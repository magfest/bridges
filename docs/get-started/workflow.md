# HOW DO I PUSH TO PROD?
The first step is to make the changes you want to test.  You MUST commit to a separate branch.  The `main` branch is limited to merge requests only, you cannot directly commit to `main`.

If you are working on a specific Jira ticket, you can start the branch name with that ticket ID (like TOPS-123) and it'll automagically add the timeline from that branch to the Jira ticket.

Once you're ready to test, you can use a branch that already exists in https://github.com/magfest/bridges/blob/main/subnet_prefixes.txt (that isn't `prod` or `main`).  If you're uncertain, use `dev`.

You'll need a VPN connection and a remote in your local repo copy that points to the event GitLab, like `git remote add MAGGitLab git@gitlab.magevent.net:magfest/bridges.git`.

Once you have that, and your branch is up to date and ready, run:
```
git push MAGGitLab HEAD:dev
```
(to use the `dev` branch as an example)

Once you push to your chosen dev branch, you'll see a new pipeline created at https://gitlab.magevent.net/magfest/bridges/-/pipelines. You can follow along with the pipeline stages and ensure there's no breakage.

Once everything is ready to merge to `main`, file an MR for your branch at https://github.com/magfest/bridges.  Other team members will review and approve if it's ready.

Then, one of us will watch the pipeline for the push to `main`.  Assuming everything goes well, we'll then push to `prod` by rebasing the `prod` branch onto `main`.
