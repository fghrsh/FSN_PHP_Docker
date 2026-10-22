## FSN PHP 8.5 Docker

PHP 8.5.12 FPM on Alpine 3.24, including the [October 2026 security fixes](https://www.php.net/archive/2026.php) for CVE-2026-109618 and CVE-2026-109619.

#### Extensions

- gd, zip, intl, soap, gettext, sockets
- redis, pgsql, pdo_pgsql, mysqli, pdo_mysql
- tidy, exif, iconv, bcmath, imagick, opcache

Redis 6.3.0 and Imagick 3.8.1 are pinned. Iconv and OPcache are provided by the base image. FTP/FTPS is built explicitly to retain the old image's functionality. XML-RPC is intentionally omitted from this branch.

#### Composer

Composer 2.10.3 is copied from the official Composer image. It uses the default official Packagist repository, with no mirror override.

#### Existing deployments

FPM workers run as `www-data` with UID/GID `82:82`, compatible with a host `www` account using those IDs. The existing PHP 7.3 `php.ini` and FPM `docker.conf` can remain mounted read-only at `/usr/local/etc/php/php.ini` and `/usr/local/etc/php-fpm.d/zz-docker.conf`. Website, log, data, and build mounts keep their existing paths.

After building or publishing the image, replace only `fghrsh/fsn_php:7.3` with `fghrsh/fsn_php:8.5` in the existing `docker run` command and recreate the container. Applications must support PHP 8.5; XML-RPC is unavailable.

#### Build and check

```sh
docker build -t fghrsh/fsn_php:8.5 .
docker run --rm -v "$PWD/tests:/tests:ro" fghrsh/fsn_php:8.5 php /tests/smoke.php
docker run --rm fghrsh/fsn_php:8.5 php-fpm -t
```
