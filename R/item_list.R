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
			#TODO: handle zip/warc formats once warc is done
			header <- get_header_contents()

			res <- getBinaryURL(paste(uri, "?format=", format, sep=""), httpheader=header)

			if(!file.exists(destination)) {
				dir.create(destination)
			}

			filename <- file.path(destination, paste(name, ".zip", sep=""))
			writeBin(as.vector(res), filename)
			return(filename)
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