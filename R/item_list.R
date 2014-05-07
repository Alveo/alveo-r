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
			res <- rjson::fromJSON(api_request(items[index]))
			return(Item(id=res$`alveo:metadata`$`alveo:handle`, uri=items[index]))
		},

		get_item_documents = function() {
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