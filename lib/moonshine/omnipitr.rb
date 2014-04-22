module Moonshine
  module Omnipitr
    def omnipitr_template_dir
      Pathname.new(__FILE__).dirname.join('omnipitr', 'templates')
    end

    def omnipitr(options = {})
      omnipitr_version = options[:version] || '1.2.0'
      options[:read_buffer_size] ||= 4096

      package 'wget', :ensure => :installed
      exec 'download omnipitr tarball',
        :command => "wget https://github.com/omniti-labs/omnipitr/archive/v#{omnipitr_version}.tar.gz -O /usr/local/src/omnipitr-#{omnipitr_version}.tar.gz",
        :creates => "/usr/local/src/omnipitr-#{omnipitr_version}.tar.gz",
        :require => package('wget')

      package 'aws-sdk',
        :ensure => :installed,
        :provider => :gem

      %w(perl perl-modules).each do |p|
        package p, :ensure => :installed, :before => exec('install omnipitr')
        end

      exec 'install omnipitr',
        :command => "tar xzvf /usr/local/src/omnipitr-#{omnipitr_version}.tar.gz &&  mkdir -p /opt/OmniPITR && cp -R /tmp/omnipitr-1.2.0/* /opt/OmniPITR/ && rm -fr /tmp/omnipitr-1.2.0",
        :cwd => '/tmp',
        :unless => "grep version /opt/OmniPITR/META.json | grep #{omnipitr_version}",
        :require => exec('download omnipitr tarball')

      file '/usr/local/bin/omnipitr-backup-s3upload',
        :ensure => :present,
        :content => template(omnipitr_template_dir.join('omnipitr-backup-s3upload'), binding),
        :require => package('aws-sdk'),
        :mode => '755'

      file '/var/lib/postgresql/.pgpass',
        :ensure => :present,
        :content => template(omnipitr_template_dir.join('pgpass'), binding),
        :mode => '600',
        :group => 'postgres',
        :owner => 'postgres'

      file '/var/log/omnipitr',
        :ensure => :directory,
        :group => 'postgres',
        :owner => 'postgres'

      file '/etc/omnipitr-backup-slave.conf',
        :ensure => :present,
        :content => template(omnipitr_template_dir.join('omnipitr-backup-slave.conf'), binding),
        :mode => '644',
        :group => 'postgres',
        :owner => 'postgres'

      if options[:cron] != false
        options[:cron] ||= {}
        cron 'omnipitr_backup_slave',
          :command => '/opt/OmniPITR/bin/omnipitr-backup-slave --config-file /etc/omnipitr-backup-slave.conf',
          :minute => options[:cron][:minute] || '30',
          :hour => options[:cron][:hour] || '02',
          :monthday => options[:cron][:monthday] || '*',
          :month => options[:cron][:month] || '*',
          :weekday => options[:cron][:weekday] || '*',
          :user => 'postgres',
          :require => [
            exec('install omnipitr'),
            file('/usr/local/bin/omnipitr-backup-s3upload'),
            file('/var/lib/postgresql/.pgpass'),
            file('/var/log/omnipitr'),
            file('/etc/omnipitr-backup-slave.conf')
          ]
      else
        cron 'omnipitr_backup_slave', :command => 'true', :ensure => :absent
      end
    end

  end
end
