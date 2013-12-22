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
			return(Item(id=res$metadata$handle, uri=uri))
		},

		search_metadata = function(query) {
			query <- URLencode(query)
			res <- api_request(paste(server_uri, "/catalog/search?metadata=", query, sep=""))
			return(fromJSON(res))
		},

		download_items = function(items, destination, name, format="zip") {
			# TODO: handle zip/warc formats once warc is complete

			zip <- api_request(paste(server_uri, "/catalog/download_items?format=", format, sep=""), data=toJSON(list(items=items)))

			if(!file.exists(destination)) {
				dir.create(destination)
			}

			filename <- file.path(destination, paste(name, ".zip", sep=""))
			writeBin(as.vector(zip), filename)
			return(filename)
		},

		create_item_list = function(items, name) {
			res <- api_request(paste(server_uri, "/item_lists?name=", URLencode(name), sep=""), data=toJSON(list(items=items)))
			return(fromJSON(res))
		},

		show = function() {
			cat("Server URI: \n")
			methods::show(server_uri)
		}
	)
)