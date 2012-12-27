<?php

/**
 * Class to parse input file and add return data with geocode information
 *
 * 
 */
class GeocodeProcessor {

	/**
	 * String to be added if geocode data was not found
	 * 
	 */
	const DATA_NOT_FOUND = 'Notfound';

	/**
	 * Default colums delimiter
	 * 
	 */
	const DEFAUL_DELIMITER = "\t";

	/**
	 * Geocoder object
	 * @var \Geocoder
	 */
	protected $geocoder;

	/**
	 * Column number to find address 
	 * @var int
	 */
	protected $column;

	/**
	 * Count of processed lines
	 * @var int
	 */
	protected $processedCount;

	/**
	 * Count of not found items
	 * @var int
	 */
	protected $notFoundCount;

	/**
	 * Array of not found items' data
	 * @var array
	 */
	protected $notFoundData;

	/**
	 * Column delimiter
	 * @var string
	 */
	protected $delimiter;

	/**
	 * Constructor: resets object and sets geocoder instance and column number 
	 * 
	 * @param \Geocoder\Geocoder
	 * @param int $column
	 */
	public function __construct(\Geocoder\Geocoder $geocoder, $column, $delimiter = self::DEFAUL_DELIMITER) {
		$this->reset();
		$this->setGeocoder($geocoder);
		$this->setColumn($column);
		$this->setDelimiter($delimiter);
	}

	/**
	 * Sets geocoder object
	 *
	 * @param \Geocoder\Geocoder $geocoder
	 */
	public function setGeocoder(\Geocoder\Geocoder $geocoder) {
		$this->geocoder = $geocoder;
	}

	/**
	 * Sets the number of the column to get address from, indexes start from 0
	 *
	 * @var int $column
	 */
	public function setColumn($column) {
		$column = (int) $column;
		if (!is_int($column) || $column < 0) {
			throw new InvalidArgumentException(sprintf('Column number should be an integer not less than 0, "%s" cannot be used', $column));
		}
		$this->column = $column;
	}

	/**
	 * Sets column delimiter
	 *
	 *
	 */
	public function setDelimiter($delimiter) {
		$this->delimiter = $delimiter;
	}

	/**
	 * Processes input line, returns original line with added columns: latitude and longitude
	 * 
	 * @param string $line
	 * @return string
	 */
	public function processLine($line) {
		$line = trim($line);
		
		$this->processedCount++;
		
		$fields = explode($this->delimiter, $line);
		$address = $fields[$this->column] ? $fields[$this->column] : '';
	
		$latitude = $longitude = self::DATA_NOT_FOUND;
		
		if ($address) {
			try {
				$result = $this->geocoder->geocode($address);
				$latitude = $result->getLatitude();
				$longitude = $result->getLongitude();
			}
			catch (Exception $E) {
				$this->notFoundData[] = $address;
				$this->notFoundCount++;
			}
		}
		return implode($this->delimiter, array_merge($fields, array($latitude, $longitude)));
	}

	/**
	 * Returns count of processed items 
	 *
	 * @return int
	 */
	public function getProcessedCount() {
		return $this->processedCount;
	}

	/**
	 * Returns count of not found items
	 *
	 * @return int
	 */
	public function getNotFoundCount() {
		return $this->notFoundCount;
	}

	/**
	 * Returns not found items data
	 *
	 * @return array
	 */
	public function getNotFoundData() {
		return $this->notFoundData;
	}

	/**
	 * Resets class state
	 * 
	 */
	protected function reset() {
		$this->column = null;
		$this->processedCount = 0;
		$this->notFoundCount = 0;
		$this->notFoundData = array();
	}
}
