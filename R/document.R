##' A class representing a single document from the Alveo virtual lab
##'
##' @field uri The URI of the document
##' @field type The document type (audio, video, text)
##' @field size The document size in bytes
##' @export Document
##' @exportClass Document
Document <- setRefClass("Document",

	fields = list(
    item = "character",
		uri = "character",
		type = "character",
		size = "character"
	),

	methods = list(

		get_content = function(binary=FALSE) {
      "Get the document at the given URL, return value may be binary data"
      
            # get documents in binary mode 
            res <- api_request(uri, binary=binary)
            
			return(res)
		},

		download = function(destination=NULL, binary=FALSE) {
            "Download the document either to the cache or a given destination directory, return the local name of the downloaded file"
            if(is.null(destination)) {
                
                filename = getCacheDocument(uri)
                
            } else {
               basename = basename(uri)
               filename = getCacheDocument(uri)
               
               # R in Windows strangely can't handle directory paths with trailing slashes
               if(substr(destination, nchar(destination), nchar(destination)+1) == "/") {
                  destination <- substr(destination, 1, nchar(destination)-1)
               }
               
               filepath = file.path(normalizePath(destination), basename)

               file.copy(from = filename, to = filepath)
               
               # TODO: the cache directory isn't being set properly so the files are being downloaded
               # to the user's current working directory. I can't seem to trace the problem down.
               # Current solution: remove the files after they've been copied to where the user wants them.
               # Noted by Nay San 10/05/2017
               file.remove(filename)

            }
			return(basename)
		},

		show = function() {
      cat("Alveo Document from item ", item, "\n")
			cat("URI: ", uri, "\n")
			cat("Type: ", type, "\n")
			cat("Size: ", size, "\n")
		}
	)
)

