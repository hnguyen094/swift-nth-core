# Pet Project
Code of [this project.](https://www.notion.so/enth/Pet-Project-64ea497a3dce4b17bef941b55c250986?pvs=4)

### Branching convention
`main`
This will be the main product goes. Will contain an Xcode Workspace that contains two Projects (iOS and visionOS) with some shared codebase (or at least shared data models.)

#### Prefixes
`exp` = experiment. Used to write up scratch code to learn something, and not to be merged as-is.<br>
`feat` = feature. Something that could be PR'd into `main` and adds a small functionality.<br>
`fix` = bug fix. Fixes a small issue with the codebase.<br>
`wip` = work-in-progress. Used for a big feature that might involve refactoring, large code changes, and/or will take a while to finish.

### Updating Data Model
To update the data model, you'll need to do a migration:
- Create a new enum (e.g. `V10`) under `AppSchema`.
- Extend this enum in the appropriate `@Model` classes that requires change, and modify the typealias at the top of the file accordingly.
- Add new `Schema` and `MigrationStage` to `AppMigrationPlan`.
- Modify `AppSchema.Latest` to the newest `Schema` version.
