#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with wlp](#setup)
    * [What wlp affects](#what-wlp-affects)
    * [Beginning with wlp](#beginning-with-wlp)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Classes](#classes)
    * [Defines](#defines)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Module for managing Websphere Liberty

## Module Description
This module allows you to install Websphere Liberty, install features or additional archives, configure/manage severs, as well as install applications.

## Setup

This module was intended for use with WLP instances that are being installed from standalone archives (zip/jar) - it does NOT make use of IBM installation manager.

### What wlp affects
Given no options except install source, wlp will:
  * Create a wlp user
  * Install java (using puppetlabs-java module)
  * Create /opt/ibm
  * Extract the supplied archive into /opt/ibm/wlp (default install location in params.pp)

No servers are created by default.  Any addtional configuration needs to be declared.

### Beginning with wlp

To start, we need to declare the base class and provide an installation source
```puppet
class {'::wlp':
  install_src => 'https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.9/wlp-javaee7-8.5.5.9.zip',
}
```

Next, we can optionally install features. ([Feature List](https://www.ibm.com/support/knowledgecenter/was_beta_liberty/com.ibm.websphere.wlp.nd.multiplatform.doc/ae/rwlp_feat.html))
```puppet
wlp::feature { 'openidConnectClient-1.0':
  ensure => present,
}
```

Once we've installed all the bits we want, we can move onto defining servers.  We need to provide the contents for the server.xml file (if left blank, you'll just get a default server.xml file).  You can setup a new server and give a config like this(just an example, you could use a template here instead of a HEREDOC, that was shown for simplicity).
```puppet
$config = @("SERVERCONFIG")
<?xml version="1.0" encoding="UTF-8"?>
<server description="new server">

    <featureManager>
        <feature>javaee-7.0</feature>
        <feature>openidConnectClient-1.0</feature>
    </featureManager>


    <basicRegistry id="basic" realm="BasicRealm">
        <!-- <user name="yourUserName" password="" />  -->
    </basicRegistry>

    <application context-root="hello_world" type="war" id="hello_world"
       location="hello_world.war" name="hello_world"/>

    <httpEndpoint id="defaultHttpEndpoint"
                  host="*"
                  httpPort="9080"
                  httpsPort="9443" />

    <applicationManager autoExpand="true"/>
</server>
| SERVERCONFIG

wlp::server{'testserver':
 ensure        => present,
 enable        => true,
 server_config => $config
}
```

Finally, we can deploy apps from within the DSL if we so choose using the following syntax:

```puppet
wlp::deploy_app{'hello_world.war':
  type        => 'static',
  server      => 'testserver',
  install_src => '/var/tmp/hello_world.war',
  ensure      => 'present',
}
```

Here's the combined configuration

```puppet
$config = @("SERVERCONFIG")
<?xml version="1.0" encoding="UTF-8"?>
<server description="new server">

    <featureManager>
        <feature>javaee-7.0</feature>
        <feature>openidConnectClient-1.0</feature>
    </featureManager>


    <basicRegistry id="basic" realm="BasicRealm">
        <!-- <user name="yourUserName" password="" />  -->
    </basicRegistry>

    <application context-root="hello_world" type="war" id="hello_world"
       location="hello_world.war" name="hello_world"/>

    <httpEndpoint id="defaultHttpEndpoint"
                  host="*"
                  httpPort="9080"
                  httpsPort="9443" />

    <applicationManager autoExpand="true"/>
</server>
| SERVERCONFIG

class {'::wlp':
  install_src => 'https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.9/wlp-javaee7-8.5.5.9.zip',
}

wlp::feature { 'openidConnectClient-1.0':
  ensure => present,
}

wlp::server{'testserver':
 ensure        => present,
 enable        => true,
 server_config => $config
}

wlp::deploy_app{'hello_world.war':
  type        => 'static',
  server      => 'testserver',
  install_src => '/var/tmp/hello_world.war',
  ensure      => 'present',
}
```

## Usage
An overview of the classes and defines that make up the wlp module

### Classes
#### `wlp`
This class is soley responsible for the base envionrment setup and installation of the actually software, it does not configure anything

_Parameters_:
  * `install_src`: Required.  Provide the path to the installation media.  Can be a zip or jar archive.
  * `manage_user`: Default True.  This parameter will cause the `wlp` user to be created.
  * `manage_java`: Default True.  This parameter will cause java to be installed via the puppetlabs-java module.
  * `base_path`: Default /opt/ibm.  This parameter controls where the software will be installed to.
  * `wlp_user`: Default wlp.  This parameter controls which user owns and runs the Liberty software.

### Defines

#### `server`
This define allows you to create and manage server instances within your WLP installation.

_Parameters_:
  * `ensure`: Default present.  Whether the server should be created or removed.
  * `enable`: Default true.  Defines if the server should be running or not.
  * `user`:  The user to run the server as.  Defaults to the wlp_user setting from the base wlp class.
  * `base_path`: The path WLP is installed.  Defaults to the base_path setting in wlp class.
  * `server_config`:  The configuration for your server.  This can be supplied via normal Puppet mechanisms (like templates).  If you DO NOT supply this you will get a default server.xml.
  * `server_env`:  This value configures the server.env file.  This can be supplied via normal Puppet mechanisms (like templates).  If you DO NOT supply this you will get a default server.env file.

_Example_
```puppet
wlp::server{'testserver':
 ensure    => present,
 enable    => true,
 server_config => $config
}
```


#### `feature`
This define allows you to install features into your base WLP installation.

_Parameters_:
  * `ensure`: Default present.  Whether or not to add or remove the feature.
  * `user`: The user to use when applying the new archive(process owner).  By default it will inherit this to however the base wlp class is configured.
  * `base_path`: The path to install to.  By default this is inherited from the base wlp class.

_Example_
```puppet
wlp::feature { 'openidConnectClient-1.0':
  ensure => present,
}
```

#### `apply_jar`
This define allows you to apply additional jar files to your WLP installation.  

_Parameters_:
  * `creates`: Required. The path to check for to validate if this archive has been previously installed.  For example `/opt/ibm/wlp/extras`
  * `install_src`: Defaults to $title.  The path to the installation media.
  * `user`: The user to use when applying the new archive(process owner).  By default it will inherit this to however the base wlp class is configured.
  * `base_path`: The path to install to.  By default this is inherited from the base wlp class, however depending on the archive it may need to be updated.
  * `java_cmd`: Default java.  The java command to use when installing this archive.

_Example_

```puppet
wlp::apply_jar{'https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.9/wlp-extended-8.5.5.9.jar':
  creates => 'lib/features/wss4j-1.0.mf',
  notify => Wlp_server_control['testserver'],
}
```

#### `deploy_app`
This define allows you to deploy an application, both dropin and static, to a WLP instance.


_Parameters_:
  * `server`: Required.  The server to install the application into.
  * `install_src`: Required.  Where to get the application archive (file/http/https)
  * `type`: Required.  The type of application this is, dropin or static.  Remember that when your deploying a static app you need to update your server config.
  * `ensure`: Default present.  The state of the application (present/absent)
  * `user`: The user to use when deploying the application.  By default it will inherit this from the base wlp class.
  * `base_path`: The path to install to.  By default this is inherited from the base wlp class.

_Examples_

```puppet
wlp::deploy_app{'hello_world.war':
  type        => 'static',
  server      => 'testserver',
  install_src => '/var/tmp/hello_world.war',
  ensure      => 'present',
}
```

## Limitations
Although WLP can run accross many platforms, this module currently only supports Linux variants.(Tested. Really anything that is Unix based *should* work but not tested).

## Development
Fork, Add tests, Update, Update CHANGELOG, Update CONTRIBUTORS, PR, repeat.

