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

		get_item_documents = function() {
            "Return a vector of all of the documents for all of the items in this item list"
			item_docs <- c()
			for(i in 1:length(items)) {
				docs <- get_item(i)$get_documents()
				for(j in 1:length(docs)) {
					item_docs <- c(item_docs, docs[[j]]$`alveo:url`)
				}
			}
			return(item_docs)
		},

		download = function(destination, format="zip") {
            "download all items in this item list, destination is the name of a directory to write the result in, format (zip or WARC or json). Returns the filename that is created."
			# R in Windows strangely can't handle directory paths with trailing slashes
			if(substr(destination, nchar(destination), nchar(destination)+1) == "/") {
				destination <- substr(destination, 1, nchar(destination)-1)
			}

			header <- get_header_contents()
			res <- getBinaryURL(paste(uri, "?format=", format, sep=""), httpheader=header, .opts = list(ssl.verifypeer = FALSE))

			if(!file.exists(destination)) {
				dir.create(destination)
			}

			filename <- file.path(destination, paste(name, format, sep="."))
			writeBin(as.vector(res), filename)
			return(filename)
		},

		get_segment_list = function(type="", label="") {
            "Query annotations on this item list and return an Emu segment list.  By default returns all annotations, specify the 'type' argument to restrict the annotation types, specify the 'label' argument to match specific labels"
			if(num_items() == 0) {
				stop("Item list cannot be empty")
			}
			segment_list=make.seglist(c(), c(), c(), c(), 'query', 'segment', 'alveo')

			for(i in 1:num_items()) {
				item <- rjson::fromJSON(api_request(paste(items[i], ".json", sep="")))
				if(!is.null(item$error) && item$error == "Invalid authentication token.") {
					stop("Invalid authentication token. Ensure the correct authentication key is in your alveo.config file")
				}
				else if(is.null(item$`alveo:annotations_url`)) {
					next #skip if item has no annotations
				}
				segments <- rjson::fromJSON(api_request(paste(item$`alveo:annotations_url`, '?type=', type, '&label=', label, sep='')))

				if(is.null(segments$error) && length(segments$`alveo:annotations`) != 0) {
					labels <- c(); starts = c(); ends = c(); utts = c()
					for(i in 1:length(segments$`alveo:annotations`)) {
						labels <- c(labels, segments$`alveo:annotations`[[i]]$label)
						starts <- c(starts, as.numeric(segments$`alveo:annotations`[[i]]$start) * 1000)
						ends <- c(ends, as.numeric(segments$`alveo:annotations`[[i]]$end) * 1000)
						utts <- c(utts, segments$commonProperties$`alveo:annotates`)
					}

					segment_list <- rbind(segment_list, make.seglist(labels, starts, ends, utts, 'query', 'segment', 'alveo'))
				}
			}
			segment_list
		},

		num_items = function() {
            "Return the number of items in this item list"
			return(length(items))
		},

		show = function() {
			cat("Name: \n")
			methods::show(name)
			cat("URI: \n")
			methods::show(uri)
			cat("Items: \n")
			methods::show(items)
		}
	)
)


##' Make a new segment list containing only the given labels
##'
##' @param seglist an Emu segment list
##' @param labels a vector of labels
##'
##' @return a new segment list containing only those labels
##' in the vector supplied
##' @export
filterSegs <- function(seglist, labels) {

    test <- label(seglist) %in% labels
    
    return(seglist[test,])
}

##' Download all files referenced by a segment list 
##'
##' Take a segment list containing URLs, download the files and
##' replace the filenames with the local names, return a new
##' segment list
##'
##' @param seglist an Emu segment list
##' @return a new segment list that references the downloaded files
##' @export
localiseSegs <- function(seglist) {
  
  urls <- unique(utt(seglist))
  
  getit <- function(uri) {  
    doc <- Document(uri=uri)
    local <- doc$download()
    return(local)
  }
  
  files <- sapply(urls, getit, USE.NAMES=FALSE)

  utts <- utt(seglist)
  for(i in 1:length(files)) {
    utts <- replace(utts, utts==urls[i], paste("file://", files[i], sep=""))
  }
  
  newsegs <- modify.seglist(seglist, utts=utts)
  return(newsegs)
}

