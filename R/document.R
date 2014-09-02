##' A class representing a single document from the Alveo virtual lab
##'
##' @field uri The URI of the document
##' @field type The document type (audio, video, text)
##' @field size The document size in bytes
##' @export Document
##' @exportClass Document
Document <- setRefClass("Document",

	fields = list(
		uri = "character",
		type = "character",
		size = "character"
	),

	methods = list(

		get_content = function() {
            "Get the document at the given URL, return value may be binary data"
			res <- api_request(uri)
            
			return(res)
		},

		download = function(destination=NULL) {
            "Download the document either to the cache or a given destination directory, return the local name of the downloaded file"
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

