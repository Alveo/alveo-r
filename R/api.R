require(rjson)
require(httr)

##' Read the user configuration file by default ~/alveo.config
##' and return a hash of keys and values
##' @title read_config
##' @param config_file Location of the configuration file to read, default is 'alveo.config' in the home directory
##' @export
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
##' @export
'api_key' <- function() {
    config <- read_config()

    return(config$apiKey)
}

##' Return the cache directory name as read from the user config file
##' @title cache_dir
##' @return cache directory name as a string
##' @export
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
##' @param url The API URL that will be used for the request
##' @param data Any data to be sent along with the request
##' @param binary A boolean, if TRUE then expect a binary result from the request
##' @return API response as json
##' @export
'api_request' <- function(url, data = NULL, binary=FALSE) {

    headers <-get_header_contents()

    if(!is.null(data)) {
        #headers$'Content-Type' <- 'application/json'
        r = POST(url, add_headers(.headers=headers), body=data, encode="json")
        response = content(r, "text")
    }
    else if (binary) {
      r = GET(url, add_headers(.headers=headers))
      response = content(r, "raw")
    }
    else {
      r = GET(url, add_headers(.headers=headers))
      response = content(r, "text")
    }
    
    return(response)
}

##' Sets default headers for Alveo API calls
'get_header_contents' <- function() {

    key <- api_key()
    return(c('X-API-KEY' = key, 'Accept' = 'application/json'))
}


##' Perform a DELETE request to a URI on the Alveo server
##' @param url The API URL that will be used for the request
##' @return API response as json
##' @export
'api_delete_request' <- function(url) {
  
    headers <- get_header_contents()
    
    r <- DELETE(url, add_headers(.headers=headers))
    
   # handle_setheaders(h, list=headers)
   # req <- httpDELETE(url, httpheader=header)

    return(content(r))
}
