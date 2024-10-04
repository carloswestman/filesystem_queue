## [Unreleased]

## [0.4.0] - 2024-10-3
- Failed jobs have added metadata including `last_exception` and `retry_count`

## [0.3.0] - 2024-09-20
- Added `reenqueue_failed_jobs` method to move failed jobs back to the queue
- Added `reenqueue_completed_jobs` method to move completed jobs back to the queue

## [0.2.0] - 2024-09-16
- Replaced old index for an in-memory index for job tracking
- Added `cleanup` method to delete files and directories created by the queue

## [0.1.1] - 2024-09-13
- Added unit tests
- Fixed Github Actions
- Minor refactors

## [0.1.0] - 2024-09-12
- Initial release
