## FSN PHP 7.4 Docker

PHP 7.4.33 FPM on Alpine 3.16, rebuilt with the [PHP security team's patch](https://github.com/php/php-src/commit/712e60f9edfd03f0960fc4fc3c2c375f42b90aa2) for CVE-2026-109618 and CVE-2026-109619. The patch download is SHA-256 verified; `php -v` still reports 7.4.33.

PHP 7.4 and Alpine 3.16 are end of life. This patch addresses those two vulnerabilities only. It disables session upload progress and immediately terminates the affected worker on memory exhaustion, without running shutdown callbacks. Multipart requests are limited to `max_input_vars + max_file_uploads` parts unless `max_multipart_body_parts` is set explicitly.

#### Extensions

- gd, zip, intl, soap, gettext, sockets
- redis, pgsql, pdo_pgsql, mysqli, pdo_mysql
- tidy, exif, iconv, bcmath, xmlrpc, imagick, opcache

Redis 6.3.0 and Imagick 3.8.1 are pinned. Iconv is provided by the base image and rebuilt PHP core.

#### Composer

Composer 2.10.3 is copied from the official Composer image. It uses the default official Packagist repository, with no mirror override.

#### Existing deployments

FPM workers run as `www-data` with UID/GID `82:82`, compatible with a host `www` account using those IDs. The existing PHP 7.3 `php.ini` and FPM `docker.conf` can remain mounted read-only at `/usr/local/etc/php/php.ini` and `/usr/local/etc/php-fpm.d/zz-docker.conf`. Website, log, data, and build mounts keep their existing paths.

After building or publishing the image, replace only `fghrsh/fsn_php:7.3` with `fghrsh/fsn_php:7.4` in the existing `docker run` command and recreate the container.

#### Build and check

```sh
docker build -t fghrsh/fsn_php:7.4 .
docker run --rm -v "$PWD/tests:/tests:ro" fghrsh/fsn_php:7.4 php /tests/smoke.php
docker run --rm fghrsh/fsn_php:7.4 php-fpm -t
```
