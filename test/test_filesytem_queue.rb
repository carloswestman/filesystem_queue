# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class FilesystemQueueTest < Minitest::Test
  def setup
    @queue_dir = 'test/fixtures/test_queue'
    @queue = FilesystemQueue::Queue.new(@queue_dir)
  end

  def teardown
    FileUtils.rm_rf(@queue_dir)
  end

  def test_initialize_creates_directories_and_index
    assert Dir.exist?(@queue.instance_variable_get(:@jobs_dir))
    assert Dir.exist?(@queue.instance_variable_get(:@completed_dir))
    assert Dir.exist?(@queue.instance_variable_get(:@failed_dir))
    assert_equal [], @queue.instance_variable_get(:@index)
  end

  def test_enqueue_adds_job_to_queue
    job = { task: 'test_task' }
    @queue.enqueue(job)
    job_file = Dir.glob("#{@queue.instance_variable_get(:@jobs_dir)}/*.json").first
    assert File.exist?(job_file)
    assert_equal job.to_json, File.read(job_file)
    assert_includes @queue.instance_variable_get(:@index), job_file
  end

  def test_dequeue_removes_and_returns_oldest_job
    job1 = { task: 'test_task_1' }
    job2 = { task: 'test_task_2' }
    @queue.enqueue(job1)
    @queue.enqueue(job2)

    dequeued_job_file, dequeued_job = @queue.dequeue
    assert_equal job1, dequeued_job
    assert File.exist?(dequeued_job_file)

    remaining_jobs = @queue.instance_variable_get(:@index)
    assert_equal 1, remaining_jobs.size
    assert_includes remaining_jobs.first, 'job_'
  end
end
