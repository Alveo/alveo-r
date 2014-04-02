RestClient <- setRefClass("RestClient",

	fields = list(
		server_uri = "character"
	),

	methods = list(

		get_api_version = function() {
			res <- fromJSON(api_request(paste(server_uri, "/version", sep="")))
			return(res$`API version`)
		},

		get_annotation_context = function() {
			res <- api_request(paste(server_uri, "/schema/json-ld", sep=""))
			return(fromJSON(res))
		},

		get_item_lists = function() {
			res <- api_request(paste(server_uri, "/item_lists", sep=""))
			return(fromJSON(res))
		},

		##' Return the item list with the given uri. The URI is derived from a call to get_item_lists and has the form /item_lists/{id}
		##' @title get_item_list
		##' @return item list as json
		get_item_list = function(uri) {
			res <- fromJSON(api_request(uri))
			return(ItemList(name=res$name, uri=uri, items=res$items))
		},

		get_item_list_by_id = function(id) {
			uri <- paste(server_uri, "/item_lists/", id, sep="")
			res <- fromJSON(api_request(uri))
			return(ItemList(name=res$name, uri=uri, items=res$items))
		},

		get_item = function(uri) {
			res <- fromJSON(api_request(uri))
			return(Item(id=res$`alveo:metadata`$`alveo:handle`, uri=uri))
		},

		search_metadata = function(query) {
			query <- URLencode(query, reserved=TRUE)
			res <- api_request(paste(server_uri, "/catalog/search?metadata=", query, sep=""))
			return(fromJSON(res))
		},

		download_items = function(items, destination, name, format="zip") {
			# R in Windows strangely can't handle directory paths with trailing slashes
			if(substr(destination, nchar(destination), nchar(destination)+1) == "/") {
				destination <- substr(destination, 1, nchar(destination)-1)
			}

			zip <- api_request(paste(server_uri, "/catalog/download_items?format=", format, sep=""), data=toJSON(list(items=items)))

			if(!file.exists(destination)) {
				dir.create(destination)
			}

			filename <- file.path(destination, paste(name, ".zip", sep=""))
			writeBin(as.vector(zip), filename)
			return(filename)
		},

		create_item_list = function(items, name) {
			res <- api_request(paste(server_uri, "/item_lists?name=", URLencode(name, reserved=TRUE), sep=""), data=toJSON(list(items=items)))
			return(fromJSON(res))
		},

		initialize = function(server_uri) {
			if(grepl("http://", server_uri)) {
				server_uri <<- sub("http://", "https://", server_uri)
			}
			else if(!grepl("https://", server_uri)) {
				server_uri <<- paste("https://", server_uri, sep="")
			}
			else {
				server_uri <<- server_uri
			}
		},

		show = function() {
			cat("Server URI: \n")
			methods::show(server_uri)
		}
	)
)