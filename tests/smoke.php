<?php

function check($condition, $message)
{
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

check(PHP_VERSION === '8.5.12', 'Unexpected PHP version');
check(!extension_loaded('xmlrpc'), 'XML-RPC must not be included');
check(extension_loaded('ftp') && function_exists('ftp_ssl_connect'), 'FTP/FTPS missing');

$extensions = ['gd', 'zip', 'intl', 'soap', 'gettext', 'sockets', 'redis',
    'pgsql', 'pdo_pgsql', 'mysqli', 'pdo_mysql', 'tidy', 'exif', 'iconv',
    'bcmath', 'imagick', 'Zend OPcache'];
foreach ($extensions as $extension) {
    check(extension_loaded($extension), "Missing extension: $extension");
}

check(bcadd('0.1', '0.2', 1) === '0.3', 'BCMath failed');
check(iconv('UTF-8', 'ISO-8859-1', "caf\xc3\xa9") === "caf\xe9", 'Iconv failed');
check(Normalizer::normalize("e\xcc\x81") === "\xc3\xa9", 'Intl failed');
check(gd_info()['JPEG Support'] && gd_info()['FreeType Support'], 'GD codecs missing');
check(strpos(tidy_repair_string('<p>hello</p>'), 'hello') !== false, 'Tidy failed');
check(in_array('mysql', PDO::getAvailableDrivers(), true), 'PDO MySQL missing');
check(in_array('pgsql', PDO::getAvailableDrivers(), true), 'PDO PostgreSQL missing');
check(!(new Redis())->isConnected(), 'Redis initialization failed');

$image = new Imagick();
$image->newImage(2, 2, 'white');
$image->setImageFormat('png');
check(substr($image->getImageBlob(), 0, 8) === "\x89PNG\r\n\x1a\n", 'Imagick PNG failed');
$image->clear();

$path = tempnam(sys_get_temp_dir(), 'fsn-zip-');
$zip = new ZipArchive();
try {
    check($zip->open($path, ZipArchive::OVERWRITE) === true, 'ZIP creation failed');
    check($zip->addFromString('hello.txt', 'hello') && $zip->close(), 'ZIP write failed');
    check($zip->open($path) === true, 'ZIP reopen failed');
    check($zip->getFromName('hello.txt') === 'hello', 'ZIP read failed');
    $zip->close();
} finally {
    unlink($path);
}

echo 'PHP ', PHP_VERSION, ': ', count($extensions), " extensions passed\n";
