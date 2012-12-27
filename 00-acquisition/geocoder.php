<?php

ini_set('auto_detect_line_endings', '1');

$file = isset($argv[1]) ? $argv[1] : '';
$column = isset($argv[2]) ? $argv[2] : '';

if (count($argv) < 2) {
	die("Usage: geocoder.php [path to file] [column number starting from 1],\ne.g. geocoder.php /path/to/file 4\n");
}

if (empty($file)) {
	die("Please specify input file\n");
}

if (!is_file($file)) {
	die(sprintf("%s is not a valid file\n"));
}

if (!is_numeric($column)) {
	die("Please specify column number\n");
}

require_once __DIR__ . '/vendor/willdurand/geocoder/src/autoload.php';
require_once __DIR__ . '/geocode_processor.php';

$adapter = new \Geocoder\HttpAdapter\CurlHttpAdapter();

$geocoder = new \Geocoder\Geocoder();
$geocoder->registerProviders(array(
	new \Geocoder\Provider\YandexProvider(
        $adapter
    )  
));

$column = $column - 1;	// starts from 1

$geocodeProcessor = new GeocodeProcessor($geocoder, $column);

$handle = fopen($file, "r");
if ($handle) {
    while (($line = fgets($handle, 4096)) !== false) {
		$geocodedLine = $geocodeProcessor->processLine($line);
		
		echo $geocodedLine . "\n"; // output to stdout

		// add debug info to console
		fwrite(STDERR, sprintf("Processed: %u, failed: %u\n", $geocodeProcessor->getProcessedCount(), $geocodeProcessor->getNotFoundCount()));

    }

    if (!feof($handle)) {
        echo "Error: unexpected fgets() fail\n";
    }

    fclose($handle);
}