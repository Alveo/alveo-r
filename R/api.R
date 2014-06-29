require(rjson)

##' Read the user configuration file by default ~/alveo.config and return a hash of keys and values
##' @title read_config
'read_config' <- function(config_file = NULL) {
	if(is.null(config_file)) {
		config_file <- file.path(Sys.getenv("HOME"), "alveo.config")
	}

	if(file.exists(config_file)) {
		configtxt <- readLines(config_file)
		config <- rjson::fromJSON(configtxt)
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
    
	if(file.exists(Sys.getenv("HOME"))) {
		home <- Sys.getenv("HOME")
	}
	else {
		stop("Make sure your $HOME environment variable is set")
	}
    
	current_dir <- getwd()
	setwd(home)

	cacheDir <- config$cacheDir

	if(!is.null(cacheDir) && file.exists(cacheDir)) {
			cacheDir <- normalizePath(cacheDir)
	}
	else if(!is.null(cacheDir) && !file.exists(cacheDir)) {
		# R in Windows strangely can't handle directory paths with trailing slashes
		if(substr(cacheDir, nchar(cacheDir), nchar(cacheDir)+1) == "/") {
			cacheDir <- substr(cacheDir, 1, nchar(cacheDir)-1)
		}
		dir.create(cacheDir)
		cacheDir <- normalizePath(cacheDir)
	}
	else {
		if(!file.exists(file.path(home, "alveo_cache"))) {
			dir.create(file.path(home, "alveo_cache"))
		}
		cacheDir <- file.path(home, "alveo_cache")
	}
	setwd(current_dir)
	return(cacheDir)
}

##' Perform a request for the given url, sending the API key along in the header, return the response
##' @title api_request
##' @return API response as json
'api_request' <- function(url, data = NULL, binary=FALSE) {
	header <- get_header_contents()

	if(!is.null(data)) {
		header <- c(header, 'Content-Type' = 'application/json')
		req <- postForm(url, .opts=list(postfields=data, httpheader=header, ssl.verifypeer = FALSE), style="POST")
	}
    else if (binary) {
		req <- getBinaryURL(url, httpheader=header, .opts = list(ssl.verifypeer = FALSE))
    }
	else {
		req <- getURL(url, httpheader=header, .opts = list(ssl.verifypeer = FALSE))
	}

	return(req)
}

##' Sets default headers for HCS vLab API calls
'get_header_contents' <- function() {
	key <- api_key()
	return(list('X-API-KEY' = key, 'Accept' = 'application/json'))
}