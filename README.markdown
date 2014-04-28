# Moonshine::Omnipitr

## Introduction

Welcome to Moonshine::Omnipitr, a [Moonshine](http://github.com/railsmachine/moonshine) plugin for installing and managing [OmniPITR](https://github.com/omniti-labs/omnipitr). This plugin installs and configures OmniPITR on the PostgreSQL slave. It configures a cron job to backup the database daily and uploads the backup to Amazon S3.

Here's some quick links:

 * [Homepage](http://github.com/railsmachine/moonshine_omnipitr)
 * [Issues](http://github.com/railsmachine/moonshine_omnipitr/issues) 
 * [Wiki](http://github.com/railsmachine/moonshine_omnipitr/wiki) 
 * [Mailing List](http://groups.google.com)
 * Resources for using OmniPITR:
   * [OmniPITR Homepage](https://github.com/omniti-labs/omnipitr)

## Quick Start

Moonshine::Omnipitr is installed as a Rails plugin:

    # Rails 2.x.x
    script/plugin install git://github.com/railsmachine/moonshine_omnipitr.git
    # Rails 3.x.x
    script/rails plugin install git://github.com/railsmachine/moonshine_omnipitr.git

Once it's installed, you can include it in your manifest:

    # app/manifests/database_manifest.rb
    class DatabaseManifest < Moonshine::Manifest:Rails

      include Moonshine::Omnipitr

      # other recipes and configuration omitted

      # tell DatabaseManifest to use the omnipitr recipe
      # omnipitr should only be setup on the slave database server
      if Facter.hostname =~ /^db2/
        recipe :omnipitr
      end
    end

Moonshine::Omnipitr requires your S3 bucket, access key, and secret key so that it can upload the backup files to S3.

## Configuration Options

Here's some other omnipitr configuration options you may be interested in.

 * `:s3_bucket`: the S3 bucket to store backups
 * `:s3_prefix`: an optional prefix to prepend to backup files (allows backups to be store in a subdirectory of the bucket)
 * `:s3_key`: your S3 access key
 * `:s3_secret`: your S3 secret key

These are namespaced under `:omnipitr`. They can be configured a few ways:

    # in global config/moonshine.yml
    :omnipitr:
      :s3_bucket: 'your-bucket'
      :s3_prefix: 'backups/'
      :s3_key: 'YOUR_ACCESS_KEY'
      :s3_secret: 'YOUR_SECRET_KEY'

    # in stage-specific moonshine.yml,
    # config/moonshine/staging.yml and config/moonshine/production.yml
    :omnipitr:
      :s3_bucket: 'your-bucket'
      :s3_prefix: 'backups/'
      :s3_key: 'YOUR_ACCESS_KEY'
      :s3_secret: 'YOUR_SECRET_KEY'

    # `configure` call in app/manifests/database_manifest.rb
    configure :omnipitr => {
      :s3_bucket => 'your-bucket',
      :s3_prefix => 'backups/',
      :s3_key    => 'YOUR_ACCESS_KEY',
      :s3_secret => 'YOUR_SECRET_KEY'
    }
    
***

Unless otherwise specified, all content copyright &copy; 2014, [Rails Machine, LLC](http://railsmachine.com)
