# frozen_string_literal: true

require "json"
require "fileutils"
require_relative "filesytem_queue/version"

module FilesytemQueue
  class Error < StandardError; end

  # A persistent queue system based on the local filesystem
  # Handles
  class Queue
    def initialize(queue_dir)
      @queue_dir = queue_dir
      @jobs_dir = File.join(@queue_dir, "jobs")
      @completed_dir = File.join(@queue_dir, "completed")
      @failed_dir = File.join(@queue_dir, "failed")
      @index_file = File.join(@queue_dir, "index.txt")

      [@jobs_dir, @completed_dir, @failed_dir].each do |dir|
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end
      FileUtils.touch(@index_file) unless File.exist?(@index_file)
    end

    def enqueue(job)
      timestamp = Time.now.to_f.to_s
      job_file = File.join(@jobs_dir, "job_#{timestamp}.json")
      File.write(job_file, job.to_json)
      File.open(@index_file, "a") { |f| f.puts(job_file) }
    end

    def dequeue
      job_file = nil
      File.open(@index_file, "r+") do |f|
        lines = f.each_line.to_a
        return nil if lines.empty?

        job_file = lines.shift.strip
        f.rewind
        f.write(lines.join)
        f.truncate(f.pos)
      end

      return nil unless job_file && File.exist?(job_file)

      job_data = JSON.parse(File.read(job_file), symbolize_names: true)
      [job_file, job_data]
    end

    def complete(job_file)
      move_job(job_file, @completed_dir)
    end

    def fail(job_file)
      move_job(job_file, @failed_dir)
    end

    def size
      File.readlines(@index_file).size
    end

    def failed_size
      Dir[File.join(@failed_dir, "*")].count { |file| File.file?(file) }
    end

    private

    def move_job(job_file, target_dir)
      FileUtils.mv(job_file, target_dir)
    rescue StandardError => e
      puts "Failed to move job file: #{e.message}"
    end
  end
end
