#!/usr/bin/env ruby

require 'colorize'
require_relative './lib/preflight_check/concourse_yml_validator'

def print_failed_jobs(result)
  puts "\nMissing Dependencies".underline
  result.failed_jobs.each do |job|
    job.missing_dependencies.each do |dep|
      puts "  Job: '#{job.name}', is missing resource: #{dep.name}"
    end
  end
end

def print_failed_resources(result)
  puts "\nUnused Resources Declared".underline
  result.failed_resources.each do |resource|
    puts "  Resource: '#{resource.name}' was defined, but never used."
  end
end


def get_manifest_path
  path = ARGV.first
  if path.nil? || path.empty?
    puts 'Include path to yml as command line argument.'.yellow
    puts 'ie. $ validate_manifest /path/to/file.yml'.yellow
    exit
  end
  path
end

def run
  path = get_manifest_path
  concourse_yml_validator = ConcourseYmlValidator.new
  result = concourse_yml_validator.validate(path: path)
  puts "\n"
  if result.success?
    puts "SUCCESS, Maifest '#{path}' is valid.".green
    puts 'You are cleared for takeoff.'

  else
    puts "FAILURE, Manifest '#{path}' is invalid.".red
    print_failed_jobs(result) unless result.failed_jobs.empty?
    print_failed_resources(result) unless result.failed_resources.empty?
  end
  puts "\n"
end

run