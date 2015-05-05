class cassandra::install {
    $jre_name = $::osfamily ? {
        'Debian'    => 'openjdk-7-jre',
        'RedHat'    => 'java-1.7.0-openjdk',
        default     => 'openjdk-7-jre',
    }

    if !defined (Package['java']) {
      package { 'java':
        ensure  => installed,
        name    => $jre_name,
      }
    }

    package { 'dsc':
        ensure  => $cassandra::version,
        name    => $cassandra::package_name,
        require => Package['java']
    }

    $python_cql_name = $::osfamily ? {
        'Debian'    => 'python-cql',
        'RedHat'    => 'python26-cql',
        default     => 'python-cql',
    }

    package { $python_cql_name:
        ensure => installed,
    }

    if ($::osfamily == 'Debian') {
        file { 'CASSANDRA-2356 /etc/cassandra':
            ensure => directory,
            path   => '/etc/cassandra',
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
        }

        exec { 'CASSANDRA-2356 Workaround':
            path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
            command => '/etc/init.d/cassandra stop && rm -rf /var/lib/cassandra/*',
            creates => '/etc/cassandra/CASSANDRA-2356',
            user    => 'root',
            require => [
                    Package['dsc'],
                    File['CASSANDRA-2356 /etc/cassandra'],
                ],
        }

        file { 'CASSANDRA-2356 marker file':
            ensure  => file,
            path    => '/etc/cassandra/CASSANDRA-2356',
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => '# Workaround for CASSANDRA-2356',
            require => [
                    File['CASSANDRA-2356 /etc/cassandra'],
                    Exec['CASSANDRA-2356 Workaround'],
                ],
        }
    }
}
