ItemList <- setRefClass("ItemList",

	fields = list(
		name = "character",
		uri = "character",
		items = "character"
	),

	methods = list(

		get_item = function(index) {
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

		download = function(destination) {
			#TODO: download item list as zip
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