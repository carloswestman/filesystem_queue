# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'filesystem_queue/version'

module FilesystemQueue
  class Error < StandardError; end

  # A persistent queue system based on the local filesystem
  # Handles
  class Queue
    def initialize(queue_dir)
      @queue_dir = queue_dir
      @jobs_dir = File.join(@queue_dir, 'jobs')
      @completed_dir = File.join(@queue_dir, 'completed')
      @failed_dir = File.join(@queue_dir, 'failed')

      [@jobs_dir, @completed_dir, @failed_dir].each do |dir|
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end

      @index = rebuild_index
    end

    def enqueue(job)
      timestamp = Time.now.to_f.to_s
      job_file = File.join(@jobs_dir, "job_#{timestamp}.json")
      File.write(job_file, job.to_json)
      @index << job_file
    end

    def dequeue
      return nil if @index.empty?

      job_file = @index.shift
      return nil unless File.exist?(job_file)

      job_data = JSON.parse(File.read(job_file), symbolize_names: true)
      [job_file, job_data]
    end

    def complete(job_file)
      move_job(job_file, @completed_dir)
    end

    def fail(job_file, exception)
      mark_failed_job(job_file, exception)
      move_job(job_file, @failed_dir)
    end

    def size
      @index.size
    end

    def failed_size
      Dir[File.join(@failed_dir, '*')].count { |file| File.file?(file) }
    end

    def retry_failed_jobs
      failed_jobs = Dir.glob(File.join(@failed_dir, '*.json'))
      failed_jobs.each do |job_file|
        new_job_file = File.join(@jobs_dir, File.basename(job_file))
        FileUtils.mv(job_file, new_job_file)
        @index << new_job_file
      end
    end

    def reenqueue_failed_jobs
      reenqueue_jobs(@failed_dir)
    end

    def reenqueue_completed_jobs
      reenqueue_jobs(@completed_dir)
    end

    # CAUTION: Cleanup the queue directory, removing all files and directories
    def cleanup
      [@jobs_dir, @completed_dir, @failed_dir].each do |dir|
        FileUtils.rm_rf(dir)
      end
      FileUtils.rm_rf(@queue_dir)
    end

    private

    def rebuild_index
      Dir.glob(File.join(@jobs_dir, '*.json')).sort
    end

    def move_job(job_file, target_dir)
      FileUtils.mv(job_file, target_dir)
      @index.delete(job_file)
    end

    def reenqueue_jobs(source_dir)
      job_files = Dir.glob(File.join(source_dir, '*.json'))
      job_files.each do |job_file|
        new_job_file = File.join(@jobs_dir, File.basename(job_file))
        FileUtils.mv(job_file, new_job_file)
        @index << new_job_file
      end
    end

    # Adds metadata for the job for the retry count and the exception details
    def mark_failed_job(job_file, exception)
      job_data = JSON.parse(File.read(job_file), symbolize_names: true)
      job_data[:retry_count] = (job_data[:retry_count] || 0) + 1
      job_data[:last_exception] = exception.message if exception
      File.write(job_file, job_data.to_json)
    end
  end
end
