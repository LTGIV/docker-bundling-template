# Docker bundling template
> A template geared towards bundling applications with Docker, and deploying them to a server to be run by systemd via Docker Compose.

# Introduction

Please allow me to start by saying, if you haven't read [How We Deploy Python Code](https://www.nylas.com/blog/packaging-deploying-python/) on the [Nylas blog](https://www.nylas.com/blog), please take the time to do so, it's an excellent read that covers a common problem.

When deploying (usually, Python-based) programs, I have 1 of 3 choices, which varies based upon my needs:

 1. [Docker Compose with systemd](https://github.com/docker/compose/issues/4266#issuecomment-302813256) - Daemons with less direct interfacing to a server.
 2. [dh-virtualenv](https://github.com/spotify/dh-virtualenv) - Daemons with more direct interfacing to a server.
 3. [Snappy](https://en.wikipedia.org/wiki/Snappy_(package_manager)) - Applications with more direct interfacing to a client (e.g. X11.)

For the purpose of this repository, the goal is #1: the higher-level needs may change, but the lower-level needs do not.  This is because I tend to use [systemd](**systemd**) and [Docker Compose](https://docs.docker.com/compose/) for running 1-n Docker containers, together as a multi-container application in a single file (e.g. [Tying MQTT, WebSockets, and Nginx together with Docker](https://thad.getterman.org/2017/09/04/tying-mqtt-websockets-and-nginx-together-with-docker)), or multiple Docker Compose-based applications independently, or together (e.g. running a Django application in a separate compose definition file that ties back to Nginx.)

# Usage

## Files to edit

### `app/`

`launch.bash` - Used for starting your program. You'll notice that the initial point in this file starts with `app/main.py`

`setup/main.bash` (optional) - Used for extending the installation process, and not a necessary edit.

`setup/modules.txt` - Python modules (1 per line.)

`setup/packages.txt` - System packages (1 per line.)

### `docker/`

`builder.yaml` - Run and synchronization parameters for scripts to run (listed in *Scripts to run* section.)

Available sections with parameters for this YAML file:

 - **build** - used by `bin/build.bash`
	 - **clean** - attempt to remove *dangling* Docker images and *exited* containers after each build.
	 - **image** - Docker image base to pull from.
	 - **version** - Docker image base version to pull from (e.g. "latest".)
 - **run** - used by `bin/run.bash`
	 - **container** - which container in your `docker-compose.yaml` and `docker-compose-develop.yaml` files to interactively run.
 - **sync** (optional) - used by `bin/sync.bash` for live syncing via SSH.
	 - **user** - remote username.
	 - **host** - remote host.
	 - **path** - remote path to synchronize to.

`docker-compose.yaml` - For deploying.

`docker-compose-develop.yaml` - For developing.

## Scripts to run

`bin/build.bash` - Used to build your Docker image, and has 2 modes to choose from via argument passed at command line:

 1. `bin/build.bash develop` (default) - Caches prerequisites, connects host volume to container, and drops you into a Bash shell.
 2. `bin/build.bash deploy` - Bundles everything together.

`bin/run.bash develop` (default) - Mostly used for developing, but good for checking your application's run for deployment (`bin/run.bash deploy`) on your remote server.

`bin/sync.bash` - useful for copying edits in real-time to a remote server, and developing (or deploying.)

# Authors/Contributors
* [Louis T. Getterman IV](https://Thad.Getterman.org/about)
* Have an improvement? Your name goes here!

> Written with [StackEdit](https://stackedit.io/).
