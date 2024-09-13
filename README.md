# FilesytemQueue

`FileSystemQueue` is a persistent queue system based on the local filesystem. It allows you to enqueue and dequeue jobs, and keeps track of completed and failed jobs.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Methods

### `initialize(queue_dir)`

Initializes the `FileSystemQueue` with the specified queue directory.

- **Parameters**:
  - `queue_dir` (String): The directory where the queue, completed, and failed job files will be stored.

### `enqueue(job)`

Enqueues a job by writing it to a new file in the `jobs` directory and appending the file path to the index file.

- **Parameters**:
  - `job` (Hash): The job data to be enqueued.

### `dequeue`

Dequeues the oldest job by reading and removing the first line from the index file, and returning the job data.

- **Returns**:
  - `Array`: An array containing the job file path and job data, or `nil` if the queue is empty.

### `complete(job_file)`

Marks a job as completed by moving the job file to the `completed` directory.

- **Parameters**:
  - `job_file` (String): The path to the job file to be marked as completed.

### `fail(job_file)`

Marks a job as failed by moving the job file to the `failed` directory.

- **Parameters**:
  - `job_file` (String): The path to the job file to be marked as failed.

### `size`

Returns the number of jobs currently in the queue.

- **Returns**:
  - `Integer`: The number of jobs in the queue.

## Usage

```ruby
# frozen_string_literal: true

require 'filesystem_queue'

queue = FilesystemQueue::Queue.new('data/queue/test')

# Enqueue jobs
jobs = [
  { task: 'process_data', data: 'first job' },
  { task: 'process_data', data: 'fail this job' },
  { task: 'process_data', data: 'third job' }
]

jobs.each { |job| queue.enqueue(job) }

# Check queue size
puts "Queue size: #{queue.size}"

# Dequeue jobs until the queue is empty
while (job_file, job = queue.dequeue)
  puts "Dequeued job: #{job} from: #{job_file}"

  # Simulate job processing
  begin
    # Process the job (replace with actual job processing logic)
    raise 'Simulated processing error' if job[:data] == 'fail this job'

    # Mark job as completed
    queue.complete(job_file)
    puts "Job completed: #{job}"
  rescue StandardError => e
    # Mark job as failed
    queue.fail(job_file)
    puts "Job failed: #{job}, Error: #{e.message}"
  end
end

puts 'Queue is empty'

# Check on failed jobs
puts "Queue size: #{queue.size}"
puts "Failed jobs: #{queue.failed_size}"
```

## Error Handling

- **`File Operations`**: The class handles errors related to file operations, such as file not found or permission denied, and prints appropriate error messages.
- **`Job Processing`**: The example usage demonstrates how to handle errors during job processing and mark jobs as failed.

## Directories

- **`jobs`**: Stores the job files that are currently in the queue.
- **`completed`**: Stores the job files that have been successfully processed.
- **`failed`**: Stores the job files that have failed during processing.

## Index File

- **`index.txt`**: Keeps track of the order of jobs in the queue. Each line in the file corresponds to a job file path.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carloswestman/filesytem_queue. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/carloswestman/filesytem_queue/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FilesytemQueue project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/carloswestman/filesytem_queue/blob/master/CODE_OF_CONDUCT.md).
