# Mauro Data Mapper Docker

The entire system can be run up using this repository
The following components are part of this system:

* Mauro Data Mapper [maurodatamapper] - Mauro Data Mapper
* Postgres 12 [postgres] - Postgres Database

## Table Of Contents

- [Mauro Data Mapper Docker](#mauro-data-mapper-docker)
  - [Table Of Contents](#table-of-contents)
  - [Dependencies](#dependencies)
  - [Building](#building)
      - [Updating](#updating)
      - [Additional Backend Plugins](#additional-backend-plugins)
      - [Multiple Instances](#multiple-instances)
      - [SSH Firewalled Servers](#ssh-firewalled-servers)
  - [Run Environment](#run-environment)
    - [Environment Notes](#environment-notes)
  - [Migrating from Metadata Catalogue](#migrating-from-metadata-catalogue)
  - [Docker](#docker)
    - [The Docker Machine](#the-docker-machine)
    - [Configuring shell to use the default Docker Machine](#configuring-shell-to-use-the-default-docker-machine)
    - [Cleaning up docker](#cleaning-up-docker)
  - [Running](#running)
    - [Optional `docker` only (no `docker-compose`)](#optional-docker-only-no-docker-compose)
  - [Developing](#developing)
    - [Running in development environment](#running-in-development-environment)
    - [Try to keep images as small as possible](#try-to-keep-images-as-small-as-possible)
    - [Make use of the wait_scripts.](#make-use-of-the-waitscripts)
    - [Use `ENTRYPOINT` & `CMD`](#use-entrypoint-cmd)
    - [`COPY` over `ADD`](#copy-over-add)
    - [`docker-compose`](#docker-compose)

---

## Dependencies

If using `Windows` or `OSX` you will need to install Docker.
Currently the minimum level of docker is

* Engine: 19.03.0+
* Compose: 1.25.0+

> :warning: **If you're running on Ubuntu**:
> the default version of `docker-compose` installed with apt-get is 1.17.1, and you might get the error message:
> ```bash
> Building docker compose
> ERROR: Need service name for --build-arg option
> ```
> In this case, you should uninstall `docker-compose` and re-install directly from Docker, following the instructions here:
> [https://docs.docker.com/compose/install/]

---

## Requirements

We advise a minimum of 2 CPUs and 4GBs RAM just to run this system this does not allow for the requirements to have an operating system running as
well. Therefore we recommend a 4 CPU and 8GB RAM server.

The default install of Docker inside Linux configures the docker engine with unlimited access to the server's resources, however if running in Windows
or Mac OS X the Docker Toolbox will need to be configured

---

## Checking out the repository

This should be possible using the normal `git checkout` command however it possible you're on an SSH firewalled server, in which case you can use the
following [SSH over HTTPS document](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/using-ssh-over-the-https
-port).

## Building

Once cloned then running the standard docker-compose build command will build the images necessary to run the services.

```bash
# Build the entire system
$ ./docker-compose build
```

### Updating

Updating an already running system can be performed in 1 of 2 ways. The **preferred** method would be to pull the latest version tag from the
repository and then rebuild the mauro-data-mapper service. However this may be hard if multiple changes have been made to the `docker-compose.yml` and
you're not familiar enough with git to handle stashing and merging.

```bash
# Update an already built system
# Fetch the latest commits
$ git fetch
# Stash any local changes
$ git stash
# Checkout/pull the version you want to update to
# e.g. git checkout B4.4.1_F6.0.0
$ git checkout <TAG>
# Unstash local changes, you may need to resolve any merge conflicts
$ git stash pop
# Build the new image
$ docker-compose build mauro-data-mapper
# Start the update
$ docker-compose up -d mauro-data-mapper
```

The alternative method is to use the update command script and pass in the new versions you want to update to. The downside with this method is if we
have made any changes to the Dockerfiles or base versions you will not have them.

```bash
# Update an already built system
# e.g ./update -b 4.4.1 -f 6.0.0
$ ./update -b <BACKEND_VERSION> -f <FRONTEND VERSION>
```

### Additional Backend Plugins

Additional plugins can be found at the [Mauro Data Mapper Plugins](https://github.com/MauroDataMapper-Plugins) organisation page. A complete list with
versions can also be found in the [installation documentation](https://maurodatamapper.github.io/installing/plugins/)
please note that while we will do our best to keep this page up-to-date there may be circumstances where it is behind, therefore we recommend using
our official GitHub Plugins organisation to find the latest releases and all available plugins.

Each of these can be added as `runtimeOnly` dependencies by adding them to the `ADDITIONAL_PLUGINS` build argument for the `mauro-data-mapper`
service build.

These dependencies should be provided in a semi-colon separated list in the gradle style, they will be split and each will be added as a `runtimeOnly`
dependency.

Example

```yml
 mauro-data-mapper:
   build:
     context: mauro-data-mapper
     args:
       ADDITIONAL_PLUGINS: "uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-excel:3.0.0"
```

Will add the Excel plugin to the `dependencies.gradle` file:

```gradle
runtimeOnly uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-excel:3.0.0
```

#### Dynamic Versions

You can use [dynamic versioning](https://docs.gradle.org/current/userguide/single_versions.html) to add dependencies, however this comes with a risk
that it pulls a version which does not comply with your expected version of mdm-application-build/mdm-core which may cause conflicts with other
plugins, therefore we do **not** advise this approach.

Example

```yml
 mauro-data-mapper:
   build:
     context: mauro-data-mapper
     args:
       ADDITIONAL_PLUGINS: "uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-excel:3.+"
```

This will add the latest minor version of the Excel plugin.

### Multiple Instances

If running multiple docker-compose instances then they will all make use of the same initial images, therefore you only need to run the `./make`
script once per server.

### SSH Firewalled Servers

Some servers have the 22 SSH port firewalled for external connections. If this is the case you can change the `base_images/sdk_base/ssh/config` file,

* comment out the `Hostname` field thats currently active * uncomment both commented out `Hostname` and `Port` fields, this will allow git to work
using the 443 port which will not be blocked.
---

## Run Environment

### postgres service

*Please see `postgres/Dockerfile` for all defaults*

* `POSTGRES_PASSWORD` - This sets the postgres user password for the service, as per the documentation at
  [Postgres Docker Hub](https://hub.docker.com/_/postgres), it must be set for a docker postgres container. We have set a default but you can override
  if desired. If you do override it, you will also need to change the `PGPASSWORD` env variable in the mauro-data-mapper section.
* `DATABASE_USERNAME` - This is the username which will be created inside the Postgres instance to own the database which the MDM service will use.
  The username is also used by the MDM service to connect to the postgres instance, therefore if you change this you *MUST* also supply it in the
  environment args for the MDM service
* `DATABASE_PASSWORD` - This is the password set for the `DATABASE_USERNAME`. It is the password used by the MDM service to connect to this postgres
  container.

### mauro-data-mapper service

*Please see `mauro-data-mapper/Dockerfile` for all defaults*

### Required to be overridden

The following variables need to be overriden/set when starting up a new mauro-data-mapper image. Usually this is done in the docker-compose.yml file.
It should not be done in the Dockerfile as each instance which starts up may use different values.

* `MDM_FQ_HOSTNAME` - The FQDN of the server where the catalogue will be accessed
* `MDM_PORT` - The port used to access the catalogue
* `MDM_AUTHORITY_URL` - The full URL to the location of the catalogue. This is considered a unique identifier to distinguish any instance from
 another and therefore no 2 instances should use the same URL.
* `MDM_AUTHORITY_NAME` - A unique name used to distinguish a running MDM instance.
* `EMAIL_USERNAME` - To allow the catalogue to send emails this needs to be a valid username for the `EMAIL_HOST`
* `EMAIL_PASSWORD` - To allow the catalogue to send emails this needs to be a valid password for the `EMAIL_HOST` and `EMAIL_USERNAME`
* `EMAIL_HOST` - This is the FQDN of the mail server to use when sending emails

### Optional

* `PGPASSWORD` - This is the postgres user's password for the postgres server. This is an environment variable set to allow the MDM service to 
  wait till the postgres service has completely finished starting up. It is only used to confirm the Postgres server is running and databases exist.
  After this it is not used again. **If you change `POSTGRES_PASSWORD` you must change this to match**
* `CATALINA_OPTS` - Java Opts to be passed to Tomcat
* `DATABASE_HOST` - The host of the database. If using docker-compose this should be left as `postgres` or changed to the name of the database service
* `DATABASE_PORT` - The port of the database
* `DATABASE_NAME` - The name of the database which the catalogue data will be stored in
* `DATABASE_USERNAME` - Username to use to connect to the database. See the Postgres service environment variables for more information.
* `DATABASE_PASSWORD` - Password to use to connect to the database. See the Postgres service environment variables for more information.
* `EMAIL_PORT` - The port to use when sending emails
* `EMAIL_TRANSPORTSTRATEGY` - The transport strategy to use when sending emails
* `SEARCH_INDEX_BASE` - The directory to store the lucene index files in
* `EMAILSERVICE_URL` - The url to the special email service, this will result in the alternative email system being used
* `EMAILSERVICE_USERNAME` - The username for the email service needs to be valid for `EMAIL_SERVICE_URL`
* `EMAILSERVICE_PASSWORD` - The password for the email service needs to be valid for `EMAIL_SERVICE_URL`

### Environment Notes

**Database** The system is designed to use the postgres service provided in the docker-compose file, therefore there should be no need to alter any of
these settings. Only make alterations if running postgres as a separate service outside of docker-compose.

**MDM_FQ_HOSTNAME** & **MDM_PORT** The provided values will be used to define the CORS allowed origins. The port will be used to define http or https
(443), if its not 80 or 443 then it will be added to the url generated. The host must be the host used in the web url when accessing the catalogue
 in a web browser.

**Email** The standard email properties will allow emails to be sent to a specific SMTP server. The `emailservice` properties override this and
send the email to the specified email service which will then forward it onto our email SMTP server.

---

## Migrating from Metadata Catalogue

Please see the [mc-to-mdm-migration](https://github.com/MauroDataMapper/mc-to-mdm-migration) repository for details.

You will need to have started up this docker service once to ensure the database and volume exists for the Mauro Data Mapper.

---

## Docker

### The Docker Machine
The default `docker-machine` in a Windows or Mac OS X environment is 1 CPU and 1GB RAM, this is not enough to run the Mauro Data Mapper system.
On Linux the docker machine is the host machine so there is no need to build or remove anything.

#### Native Docker

If using the Native Docker then edit the preferences of the Docker application and increase the RAM to at least 4GB,
you will probably need to restart Docker after doing this.

#### Docker Toolbox

If using the Docker Toolbox then as such you will need to perform the following in a 'docker' terminal.

```bash
# Stop the default docker machine
$ docker-machine stop default

# Remove the default machine
$ docker-machine rm default

# Replace with a more powerful machine (4096 is the minimum recommended RAM, if you can give it more then do so)
$ docker-machine create --driver virtualbox --virtualbox-cpu-count "-1" --virtualbox-memory "4096" default
```

##### Configuring shell to use the default Docker Machine

When controlling using Docker Machine via your terminal shell it is useful to set the `default` docker machine.
Type the following at the command line, or add it to the appropriate bash profile file:

```bash
eval "$(docker-machine env default)"
```

If not you may see the following error: `Cannot connect to the Docker daemon. Is the docker daemon running on this host?`


### Cleaning up docker

Continually building docker images will leave a lot of loose snapshot images floating around, occasionally make use of:

* Clean up stopped containers - `docker rm $(docker ps -a -q)`
* Clean up untagged images - `docker rmi $(docker images | grep "^<none>" | awk "{print $3}")`
* Clean up dangling volumes - `docker volume rm $(docker volume ls -qf dangling=true)`

You can make life easier by adding the following to the appropriate bash profile file:

```bash
alias docker-rmi='docker rmi $(docker images -q --filter "dangling=true")'
alias docker-rm='docker rm $(docker ps -a -q)'
alias docker-rmv='docker volume rm $(docker volume ls -qf dangling=true)'
```

Remove all stopped containers first then remove all tagged images.

A useful tool is [Dockviz](https://github.com/justone/dockviz),
ever since docker did away with `docker images --tree` you can't see all the layers of images and therefore how much floating mess you have.

Add the following to to the appropriate bash profile file:

 ```bash
 alias dockviz="docker run --privileged -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz"
 ```

Then in a new terminal you can run `dockviz images -t` to see the tree,
the program also does dot notation files for a graphical view as well.

### Multiple compose files

When you supply multiple files, docker-compose combines them into a single configuration.
Compose builds the configuration in the order you supply the files.
Subsequent files override and add to their successors.

```bash
# Apply the .dev yml file, create and start the containers in the background
$ docker-compose -f docker-compose.yml -f docker-compose.dev.yml -d <COMMAND>

# Apply the .prod yml file, create and start the containers in the background
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml -d <COMMAND>
```

We recommend adding the following lines to the appropriate bash profile file:

```bash
alias docker-compose-dev="docker-compose -f docker-compose.yml -f docker-compose.dev.yml"
alias docker-compose-prod="docker-compose -f docker-compose.yml -f docker-compose.dev.yml"
```
This will allow you to start compose in dev mode without all the extra file definitions

---

## Running

Before running please read the [parameters](parameters) section first.

With `docker` and `docker-compose` installed, run the following:

```bash
# Build all the images
$ docker-compose-dev build

# Start all the components up
$ docker-compose up -d

# To only start 1 service
# This will also start up any of the services the named service depends on (defined by `links` or `depends_on`)
$ docker-compose up [SERVICE]

# To push all the output to the background add `-d`
$ docker-compose up -d [SERVICE]

# Stop background running and remove the containers
$ docker-compose down

# To update an already running service
$ docker-compose-dev build [SERVICE]
$ docker-compose up -d --no-deps [SERVICE]

# To run in production mode
$ docker-compose-prod up -d [SERVICE]
```

If you run everything in the background use `Kitematic` to see the individual container logs.
You can do this if running in the foreground and its easier as it splits each of the containers up.

If only starting a service when you stop the service docker will *not* stop the dependencies that were started to allow the named service to start.

The default compose file will pull the correct version images from Bintray, or a locally defined docker repository.

---

## Developing

### Running in development environment

There is an extra override docker-compose file for development, this currently opens up the ports in

* postgres

### Building images

The `.dev` compose file builds all of the images,
the standard compose file and `.prod` versions **do not** build new images.


**Try to keep images as small as possible**

### Make use of the wait_scripts.

While `-links` and `depends_on` make sure the services a service requires are brought up first Docker only waits till they are running NOT till they
are actually ready.
The wait scripts allow testing to make sure the service is actually available.

**Note**: If requiring postgres and using any of the Alpine Linux base images then the Dockerfile  will need to add the following:

`RUN apk add postgresql-client`

### Use `ENTRYPOINT` & `CMD`

* If not requiring any dependencies then just set `CMD ["arg1", ...]` and the args will be passed to the `ENTRYPOINT`
* If requiring dependencies then set the `ENTRYPOINT` to the wait script and the `CMD` to `CMD ["process", "arg1", ...]`

**Note**: We should be able to override the `ENTRYPOINT` in the docker-compose but for some reason its not then passing the CMD args through.

### `COPY` over `ADD`

Docker recommends using COPY instead of ADD unless the source is a URL or a tar file which ADD can retrieve and/or unzip.,=

### `docker-compose`

Careful thought about what is required and what ports need to be passed through.
If the port only needs to be available to other docker services then use `expose`.
If the port needs to be open outside (e.g. the LabKey port 8080) then use `ports`.

If the `ports` option is used this opens the port from the service to the outside world,
it does not affect `exposed` ports between services, so if a service (e.g. postgres with port 5432) exposes a port
then any service which used `link` to `postgres` will be able to find the database at `postgresql://postgres:5432`

## Releases

All work should be done on the `develop` branch.
