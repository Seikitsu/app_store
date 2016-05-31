# encoding: utf-8

puts 'YOU ARE RUNNING ON DEVELOPMENT VERSION OF THE DOWNLOADER. IF YOU ARE USING THIS IN PRODUCTION, MIGRATE TO STABLE VERSION ASAP!!!'

require 'fileutils'

fetch_gems = true
repo_gems = [
    'https://gdc-ms-ruby-packages.s3.amazonaws.com/gooddata_connectors_base/s3.zip',
    'https://gdc-ms-ruby-packages.s3.amazonaws.com/gooddata_connectors_metadata/bds_implementation_devel_validation.zip',
    'https://gdc-ms-ruby-packages.s3.amazonaws.com/gooddata_connectors_downloader_csv/development_validation.zip'
]
if fetch_gems
  repo_gems.each do |repo_gem|
    cmd = "curl -LOk --retry 3 #{repo_gem} 2>&1"
    puts cmd
    system(cmd)

    repo_gem_file = repo_gem.split('/').last

    cmd = "unzip -o #{repo_gem_file} 2>&1"
    puts cmd
    system(cmd)

    FileUtils.rm repo_gem_file
  end
end

# Bundler hack
require 'bundler/cli'
Bundler::CLI.new.invoke(:install, [],:path => "gems",:jobs => 4,:deployment => true)



# Required gems
require 'bundler/setup'
require 'gooddata'
require 'gooddata_connectors_metadata'
require 'gooddata_connectors_downloader_csv'

# Require executive brick
require_relative 'execute_brick'

FileUtils.mkdir_p('tmp')

include GoodData::Bricks

#GoodData.logging_on

# Prepare stack
stack = [
  LoggerMiddleware,
  BenchMiddleware,
  GoodDataCustomMiddleware,
  GoodData::Connectors::Metadata::MetadataMiddleware,
  GoodData::Connectors::DownloaderCsv::CsvDownloaderMiddleWare,
  ExecuteBrick
]

# Create pipeline
p = GoodData::Bricks::Pipeline.prepare(stack)

# Default script params
$SCRIPT_PARAMS = {} if $SCRIPT_PARAMS.nil?

# Setup params
$SCRIPT_PARAMS['GDC_LOGGER'] = Logger.new(STDOUT)

# Execute pipeline
p.call($SCRIPT_PARAMS)