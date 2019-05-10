##' A class representing an Alveo Item List
##' 
##' @field name The item list name
##' @field uri The uri for the item list on the Alveo server
##' @field items A list of items in the item list
##' @export ItemList
##' @exportClass ItemList
ItemList <- setRefClass("ItemList",

	fields = list(
		name = "character",
		uri = "character",
		items = "character"
	),

	methods = list(

		get_item = function(index) {
            "Get an item given the (numerical) index, returns an Item object"
			if(index > length(items) || index < 1) {
				stop('index out of bounds')
			}
			res <- rjson::fromJSON(api_request(items[index]))
			return(Item(id=res$`alveo:metadata`$`alveo:handle`, uri=items[index]))
		},

		get_item_documents = function(types=NULL, pattern=NULL) {
      "Return a vector of all of the documents for all of the items in this item list.
      If type is given, it should be a sequence of type names, return only documents
      of with dc:type in this sequence, eg. ('Audio', 'TextGrid').
      If pattern is given, return only documents with dc:identifier matching this regular expression"
			item_docs <- c()
			for(i in 1:length(items)) {
				docs <- get_item(i)$get_documents(types=types, pattern=pattern)
                    for(j in 1:length(docs)) {
                      item_docs <- c(item_docs, docs[[j]])
                    }
			}
			return(item_docs)
		},

		download = function(destination, type=NULL, pattern=NULL) {
      "Download all items in this item list, destination is the name of a directory 
  		to write the result in, format (zip or WARC or json). 
  		Returns the filename that is created."
			
		  # R in Windows strangely can't handle directory paths with trailing slashes
      if(substr(destination, nchar(destination), nchar(destination)+1) == "/") {
          destination <- substr(destination, 1, nchar(destination)-1)
      }
      
      # ensure that the destination directory exists
      dir.create(destination, showWarnings=FALSE)
      
      getit <- function(doc) {
        local <- doc$download(destination, binary=TRUE)
        return(local)
      }
      
      docs <- get_item_documents(type=type, pattern=pattern)
      
      files <- sapply(docs, getit, USE.NAMES=FALSE)

      return(files)
		},
    
		num_items = function() {
    "Return the number of items in this item list"
			return(length(items))
		},

		show = function() {
			cat("Name: ", name, "\n")
			cat("URI: ", uri, "\n")
			cat("Items: \n")
			methods::show(items)
		}
	)
)
