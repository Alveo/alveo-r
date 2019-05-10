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
		
		download = function(destination, binary=FALSE) {
      "Download the document to a given destination directory, return the local name of the downloaded file"
       basename = basename(uri)
       

       # R in Windows strangely can't handle directory paths with trailing slashes
       if(substr(destination, nchar(destination), nchar(destination)+1) == "/") {
          destination <- substr(destination, 1, nchar(destination)-1)
       }
       
       filepath = file.path(normalizePath(destination), basename)
       
       res <- api_request(uri, binary=TRUE)
       writeBin(res, filepath)
		   return(filepath)
		},

		show = function() {
      cat("Alveo Document from item ", item, "\n")
			cat("URI: ", uri, "\n")
			cat("Type: ", type, "\n")
			cat("Size: ", size, "\n")
		}
	)
)


#' Download a document to a given directory
#' 
#' @param uri The URI of the document on Alveo
#' @param destination The directory to store the downloaded file
#' @param binary If TRUE (default), download the data as binary, otherwise download as text
#' 
#' @return The name of the local file
#' 
document_download <- function(uri, destination, binary=TRUE) {

  basename = basename(uri)
  
  # R in Windows strangely can't handle directory paths with trailing slashes
  if(substr(destination, nchar(destination), nchar(destination)+1) == "/") {
    destination <- substr(destination, 1, nchar(destination)-1)
  }
  
  filepath = file.path(normalizePath(destination), basename)
  
  res <- document_content(uri, binary=binary)
  writeBin(res, filepath)
  return(filepath)
}


#' Return the contents of a document
#' 
#' @param uri The URI of the document on Alveo
#' @param binary If TRUE, download the data as binary, otherwise (default) download as text
#'
#' @return The content of the file
#' 
document_content = function(uri, binary=FALSE) {

  res <- api_request(uri, binary=binary)
  
  return(res)
}