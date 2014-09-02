require(digest)

##' Downloads a single document from a URL to a local cache, uses
##'  cached version if present
##' 
##' @param url The URL to download
##' @param content Boolean to determine whether the file content is returned, default FALSE
##' @return If content=FALSE (default) the name of the local version of the downloaded file,
##'    otherwise return the content of the downloaded or cached file
##' @author Matt Hillman
##' @examples
##' 
##' 
##' #   local <- getCacheDocument(url)
##' #   data <- getCacheDocument(url, content=TRUE)
##' 
##' 
'getCacheDocument' <- function(url, content=FALSE) {

	tmpFilename <- getCacheName(url)
        
	if(file.exists(tmpFilename)) {
        if (content) {
            res <- readBin(tmpFilename, raw())
        }
    } else {
		res <- api_request(url, binary=TRUE)
		writeBin(res, tmpFilename)
		writeCacheListing(url, tmpFilename)
    }
    if(content) {
        return(res)
    } else {
        return(tmpFilename) 
    }
}

##' getCacheName
##' @param url The URL we want to cache
##' @return a local filename to use for a downloaded file
getCacheName <- function(url) {
    
	config <- read_config()
    directory <- cache_dir()
    
    base <- paste(config$base_url, "catalog/", sep="")
    
    if( substring(url, 1, nchar(base)) == base)  {
        path <- substring(url, nchar(base)+1)
        local <- file.path(directory, path)
        if( !file.exists(dirname(local)) ) {
            dir.create(dirname(local), recursive=T, showWarnings=F)
        }
    } else {
        local <- paste(digest::digest(url, "md5"), ".", file_ext(url), sep="")
    }
    return(local)
}

##' Records the uri to filename mapping to the cache contents file
##' @title writeCacheListing
##' @param uri The URI being cached
##' @param filename The local filename that was used to cache the file
'writeCacheListing' <- function(uri, filename) {
	directory <- cache_dir()
	write(paste(uri, filename, sep=" -> "), file=file.path(directory, "cache_contents"), append=TRUE, sep="\n")
}


##' Opens the cache contents file to display list of files in the cache with their mappings
##' 
##' @return A file containing the list of files in the cache
##' @title viewCache
'viewCache' <- function() {
	directory <- cache_dir()
	cache <- file.path(directory, "cache_contents")
	if(!file.exists(cache)) {
		file.create(cache)
	}
	file.show(cache)
}


##' Deletes all the files currently in the cache directory
##' @title emptyCache
'emptyCache' <- function() {
	directory <- cache_dir()
	unlink(directory, recursive=T)
    dir.create(directory)
	file.create(file.path(directory, "cache_contents"))
	return(TRUE)
}


##' Removes requested file from the cache if it exists
##' @title removeItemFromCache
##' @param filename the name of the local file to remove from the cache
'removeItemFromCache' <- function(filename) {
	directory <- cache_dir()
	if(file.exists(file.path(directory, filename))) {
		unlink(file.path(directory, filename))
		con  <- file(file.path(directory, "cache_contents"), open = "r")
		files <- c()
		while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
			if(length(grep(filename, oneLine)) == 0) {
				files <- c(files, oneLine)
			}
		}
		close(con)
		write(files, file=file.path(directory, "cache_contents"), sep="\n")
	}
	else {
		stop("File not found in cache")
	}
}

