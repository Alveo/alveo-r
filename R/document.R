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
			header <- get_header_contents()

			res <- getURLContent(uri, httpheader=header)
			return(res)
		},

		##' Download the document and store it in the directory 'destination'. Create the directory if it doesn't exist
		##' @title download_document
		##' @return local name of the downloaded file
		download = function(destination) {
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