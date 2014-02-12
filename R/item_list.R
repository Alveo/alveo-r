ItemList <- setRefClass("ItemList",

	fields = list(
		name = "character",
		uri = "character",
		items = "character"
	),

	methods = list(

		get_item = function(index) {
			if(index > length(items) || index < 1) {
				stop('index out of bounds')
			}
			res <- fromJSON(api_request(items[index]))
			return(Item(id=res$metadata$handle, uri=items[index]))
		},

		get_item_documents = function() {
			item_docs <- c()
			for(i in 1:length(items)) {
				docs <- get_item(i)$get_documents()
				for(j in 1:length(docs)) {
					item_docs <- c(item_docs, docs[[j]]$url)
				}
			}
			return(item_docs)
		},

		download = function(destination, format="zip") {
			# R in Windows strangely can't handle directory paths with trailing slashes
			if(substr(destination, nchar(destination), nchar(destination)+1) == "/") {
				destination <- substr(destination, 1, nchar(destination)-1)
			}

			header <- get_header_contents()
			res <- getBinaryURL(paste(uri, "?format=", format, sep=""), httpheader=header)

			if(!file.exists(destination)) {
				dir.create(destination)
			}

			filename <- file.path(destination, paste(name, ".zip", sep=""))
			writeBin(as.vector(res), filename)
			return(filename)
		},

		get_segment_list = function(type="", label="") {
			if(num_items() == 0) {
				stop("Item list cannot be empty")
			}
			segment_list=make.seglist(c(), c(), c(), c(), 'query', 'segment', 'hcsvlab')

			for(i in 1:num_items()) {
				item <- fromJSON(api_request(paste(items[i], ".json", sep="")))
				if(!is.null(item$error) && item$error == "Invalid authentication token.") {
					stop("Invalid authentication token. Ensure the correct authentication key is in your hcsvlab.config file")
				}
				else if(is.null(item$annotations_url)) {
					next #skip if item has no annotations
				}
				segments <- fromJSON(api_request(paste(item$annotations_url, '?type=', type, '&label=', label, sep='')))

				if(is.null(segments$error) && length(segments$annotations) != 0) {
					labels <- c(); starts = c(); ends = c(); utts = c()
					for(i in 1:length(segments$annotations)) {
						labels <- c(labels, segments$annotations[[i]]$label)
						starts <- c(starts, as.numeric(segments$annotations[[i]]$start) * 1000)
						ends <- c(ends, as.numeric(segments$annotations[[i]]$end) * 1000)
						utts <- c(utts, segments$commonProperties$annotates)
					}

					segment_list <- rbind(segment_list, make.seglist(labels, starts, ends, utts, 'query', 'segment', 'hcsvlab'))
				}
			}
			segment_list
		},

		num_items = function() {
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