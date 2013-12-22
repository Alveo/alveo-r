##' Read the user configuration file by default ~/hcsvlab.config and return a hash of keys and values
##' @title read_config
'read_config' <- function(config_file = NULL) {
	if(is.null(config_file)) {
		config_file <- file.path(Sys.getenv("HOME"), "hcsvlab.config")
	}

	if(file.exists(config_file)) {
		config <- fromJSON(file=config_file)
	}
	else {
		stop(cat("Config file ", config_file, " not found"))
	}
	return(config)
}

##' Return the API key as read from the user config file
##' @title api_key
##' @return API key as a string
'api_key' <- function() {
	config <- read_config()

	return(config$apiKey)
}

##' Return the cache directory name as read from the user config file
##' @title cache_dir
##' @return cache directory name as a string
'cache_dir' <- function() {
	config <- read_config()

	return(config$cacheDir)
}

##' Perform a request for the given url, sending the API key along in the header, return the response
##' @title api_request
##' @return API response as json
'api_request' <- function(url, data = NULL) {
	header <- get_header_contents()

	if(!is.null(data)) {
		header <- c(header, 'Content-Type' = 'application/json')
		req <- postForm(url, .opts=list(postfields=data, httpheader=header), style="POST")
	}
	else {
		req <- getURL(url, httpheader=header)
	}

	return(req)
}

##' Sets default headers for HCS vLab API calls
'get_header_contents' <- function() {
	key <- api_key()
	return(list('X-API-KEY' = key, 'Accept' = 'application/json'))
}