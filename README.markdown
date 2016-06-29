#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with wlp](#setup)
    * [What wlp affects](#what-wlp-affects)
    * [Beginning with wlp](#beginning-with-wlp)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Module for managing Websphere Liberty Profile 

## Module Description


## Setup

### What wlp affects


### Beginning with wlp

Example installing one server, features, and configuring config file

```puppet
$config = @("SERVERCONFIG")
<?xml version="1.0" encoding="UTF-8"?>
<server description="new server">
    <featureManager>
        <feature>javaee-7.0</feature>
    </featureManager>

    <keyStore password=""/>

    <basicRegistry id="basic" realm="BasicRealm">
    </basicRegistry>

    <httpEndpoint id="defaultHttpEndpoint"
                  httpPort="9080"
                  httpsPort="9443" />
    <applicationManager autoExpand="true"/>
</server>
| SERVERCONFIG


Wlp_feature {
  base_path => '/opt/ibm/wlp',
  wlp_user  => 'wlp',
}

class {'wlp':
  install_src = '/tmp/wlp-javaee7-16.0.0.2.zip'
}

wlp_feature{'adminCenter-1.0':
  ensure => present,
}
wlp_feature{'openidConnectClient-1.0':
  ensure        => present,
  install_from  => '/tmp/openid/'
}

wlp::server{'testserver':
 ensure        => present,
 enable        => true,
 base_path     => '/opt/ibm/wlp',
 user          => 'wlp',
 server_config => $config
}
```

## Usage


## Reference

## Limitations


## Development
Fork, Update, Update CHANGELOG, Update CONTRIBUTORS, PR, repeat.

