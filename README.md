Symfony Application in Docker
=====================

This repository contains the standard [Symfony](https://symfony.com/doc/current/setup.html) application, packaged in [Docker](https://docs.docker.com/) containers with the ability to run using [Docker-Compose](https://docs.docker.com/compose/).

***

When creating this project, I was inspired by this article <https://habr.com/en/post/461687/>

***

### Stack:
* [PostgreSQL](https://www.postgresql.org/) [v11.4]
* [Redis](https://redis.io/) & [Redis Commander](https://github.com/joeferner/redis-commander) [v5.0.5]
* [PHP 7.4](https://www.php.net/ChangeLog-7.php#7.4.1) with [xDebug](https://xdebug.org/) [v2.9.0] in DEV build
* [Symfony](https://symfony.com/doc/current/setup.html) [v5.3.*]
* [RoadRunner](https://github.com/spiral/roadrunner) [v2.1.3]
* Makefile [RUS](https://blog.hook.sh/nix/makefile-full-doc/) leadership, [EN](https://www.gnu.org/software/make/manual/make.html) official docs

# Installation

Clone the repository
<br/>

```bash
$ git clone https://github.com/renay/symfony-docerized
```

# Usage

Need to build base image:
```bash
$ chmod +x ./docker/php/build.sh
$ ./docker/php/build.sh -t app/php:$VERSION
```
<br/>

After you need to build an application image:
```bash
$ chmod +x ./docker/app/build.sh
$ ./docker/app/build.sh --parent app/php:$VERSION -t app/app:$VERSION -m [--mode] 'dev' 
```
<br/>

And you need to lift all the containers:
```bash
$ docker-compose up -d
```
That's all. Now you can get to work :blush:

# Options
Name            | Accepted Values         | Example                   | Description
----------------|-------------------------|---------------------------|----------------------
-m or --mode     | __dev__ or __prod__     | dev                       | This argument indicates which Dockerfile to use for the build environment _(Dockerfile.dev or Dockerfile.prod)_.
-t              | name:tag                | app/{container}:{version} | Name and optionally a tag in the ‘name:tag’ format.

May accept other options from https://docs.docker.com/engine/reference/commandline/build/

# Contributing
Soon...

# Documentation
Coming soon...
