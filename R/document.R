Document <- setRefClass("Document",

	fields = list(
		uri = "character",
		type = "character",
		size = "character"
	),

	methods = list(

		##' Get the document at the given URL
		##' @title get_document
		##' @return document, which may be binary data
		get_content = function() {
			res <- api_request(uri)
            
			return(res)
		},

		##' Download the document either to the cache or a given destination directory
		##' @title download_document
        ##' @param destination the destination directory (optional)
		##' @return local name of the downloaded file
        ##' 
		download = function(destination=NULL) {
            
            if(is.null(destination)) {
                
                filename = getCacheDocument(uri)
                
            } else {
                
    			# R in Windows strangely can't handle directory paths with trailing slashes
    			if(substr(destination, nchar(destination), nchar(destination)+1) == "/") {
    				destination <- substr(destination, 1, nchar(destination)-1)
    			}
			
    			content <- get_content()

    			if(!file.exists(destination)) {
    				dir.create(destination)
    			}

    			basename <- basename(uri)
    			filename <- file.path(destination, basename)

    			writeBin(as.vector(content), filename)

            }
			return(filename)
		},

		show = function() {
			cat("URI: \n")
			methods::show(uri)
			cat("Type: \n")
			methods::show(type)
			cat("Size: \n")
			methods::show(size)
		}
	)
)