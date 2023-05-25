<?php
function ngrok_url($url)
{
    $options = [
        'http' => [
            'header' => 'Content-Type: application/json',
            'method' => 'GET',
        ],
    ];

    $context = stream_context_create($options);

    $urls = [];

    try {
        $data = file_get_contents($url, false, $context);
        $jsonData = json_decode($data);

        if (!empty($jsonData->tunnels)) {
            foreach ($jsonData->tunnels as $tunnel) {
                $urls[$tunnel->name] = $tunnel->public_url;
            }
        }
    } catch (\Exception $ex) {
    }

    return $urls;
}

$urls = ngrok_url('http://ngrok:4040/api/tunnels');

if (!empty($urls['nginx'])) {
    $siteUrl = $urls['nginx'];
    [$scheme, $publicDomain] = explode('://', $urls['nginx']);
    define('WP_HOME', $siteUrl);
    define('WP_SITEURL', $siteUrl);

    define('.COOKIE_DOMAIN.', $publicDomain);
    define('.SITECOOKIEPATH.', '.');

    if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $list = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        $_SERVER['REMOTE_ADDR'] = $list[0];
    }

    $_SERVER['HTTP_HOST'] = $publicDomain;
    $_SERVER['REMOTE_ADDR'] = $siteUrl;
    $_SERVER['SERVER_ADDR'] = $publicDomain;
    $_SERVER['HTTPS'] = $scheme == 'https';
    $_SERVER['SERVER_NAME'] = $_SERVER['APP_HOST'];
}

defined('WP_HOME') or define('WP_HOME', $_SERVER['REQUEST_SCHEME'] . '://' . $_SERVER['SERVER_NAME']);
defined('WP_SITEURL') or define('WP_SITEURL', $_SERVER['REQUEST_SCHEME'] . '://' . $_SERVER['SERVER_NAME']);