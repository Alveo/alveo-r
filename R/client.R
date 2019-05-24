require(rjson)

#' A class representing a link to the Alveo virtual laboratory
#' 
#' RestClient(server_uri)
#' \code{server_uri} is the URI of the Alveo server
#'
#' @examples  
#' # read the configuration file \code{alveo.config}
#' config <- read_config()
#' # create a client using the URI from the configuration
#' client <- RestClient(server_uri=config$base_url) 
#'
#' @field server_uri The URI of the Alveo server
#' @export RestClient
#' @exportClass RestClient
#' @import rjson
#' @import httr
RestClient <- setRefClass("RestClient",

	fields = list(
		server_uri = "character"
	),

	methods = list(

	  initialize = function(uri="https://app.alveo.edu.au/", ...) {
	    server_uri <<- uri
	  },
	  
		get_api_version = function() {
            "Return the current API version number"
			res <- rjson::fromJSON(api_request(paste(server_uri, "/version", sep="")))
			return(res$`API version`)
		},

		get_annotation_context = function() {
            "Return the annotation context"
			res <- api_request(paste(server_uri, "/schema/json-ld", sep=""))
			return(rjson::fromJSON(res))
		},

		get_item_lists = function() {
            "Return all of the item lists accessible to this user"
			res <- api_request(paste(server_uri, "/item_lists", sep=""))
			return(rjson::fromJSON(res))
		},

		get_item_list = function(uri) {
            "Return the item list with the given uri."
			res <- rjson::fromJSON(api_request(uri))
			return(ItemList(name=res$name, uri=uri, items=res$items))
		},

		get_item_list_by_id = function(id) {
            "Return an item list given its identifier"
			uri <- paste(server_uri, "/item_lists/", id, sep="")
			res <- rjson::fromJSON(api_request(uri))
			return(ItemList(name=res$name, uri=uri, items=res$items))
		},

    get_item_list_by_name = function(name) {
      "Return an item list given its name"
      
      uri <- get_item_list_uri_by_name(name)
      if (is.null(uri)) {
        return(NULL)
      } else {
        res <- rjson::fromJSON(api_request(uri))
        return(ItemList(name=res$name, uri=uri, items=res$items))
      }
    },
    
    get_item_list_uri_by_name = function(name) {
        "Return an item list uri given it's name, 
        if no such list is found, return NULL"
        info <- get_item_lists()
        # find out item list in the result and return the URL
        for (el in info$own) {
          if (el$name == name) {
            return(el$item_list_url)
          }
        }
        for (el in info$shared) {
          if (el$name == name) {
            return(el$item_list_url)
          }
        }
        return(NULL)
    },

	get_item = function(uri) {
        "Return an item given its URI. Returns an Item object."
		res <- rjson::fromJSON(api_request(uri))
		return(Item(id=res$`alveo:metadata`$`alveo:handle`, uri=uri))
	},

	search_metadata = function(query) {
        "Search metadata using the given query, return a list of items."
		query <- URLencode(query, reserved=TRUE)
		uri <- paste(server_uri, "/catalog/search?metadata=", query, sep="")
		res <- api_request(uri)
		return(rjson::fromJSON(res))
	},

	download_items = function(items, destination, name, format="zip") {
        "download all items in this list of items, destination is the name of a directory to write the result in, format (zip or WARC or json). Returns the filename that is created."
		# R in Windows strangely can't handle directory paths with trailing slashes
		if(substr(destination, nchar(destination), nchar(destination)+1) == "/") {
			destination <- substr(destination, 1, nchar(destination)-1)
		}
	  data = NULL
	  data$items = items
		zip <- api_request(paste(server_uri, "/catalog/download_items?format=", format, sep=""), data=data)

		if(!file.exists(destination)) {
			dir.create(destination)
		}

		filename <- file.path(destination, paste(name, ".zip", sep=""))
		writeBin(as.vector(zip), filename)
		return(filename)
	},

	create_item_list = function(items, name) {
        "Create an item list on the Alveo server given a list of items (eg. the result of a query from search_metadata)"
	  data = NULL
	  data$items = items
		res <- api_request(paste(server_uri, "/item_lists?name=", URLencode(name, reserved=TRUE), sep=""), data=data)
		return(rjson::fromJSON(res))
	},
    
    delete_item_list = function(uri) {
        "Delete the item list with the given uri"
        res <- api_delete_request(uri)
        return(res)
    },

    sparql = function(query, collection) {
        "Run a SPARQL query on the Alveo server against the given collection. Return the result."
        res <- api_request(paste(server_uri, "/sparql/", collection, "?query=", URLencode(query, reserved=TRUE), sep=""))
        return(rjson::fromJSON(res))
    },

  	get_contributions = function() {
  	  "Get a list of contributions. Return a list with components $own and $shared,
  	   each contains a list of $id, $name, $url, $accessible"
  	  
  	  res <- api_request(paste(server_uri, "contrib", sep=""))
  	  return(rjson::fromJSON(res))
  	},
	
	
	  get_contribution = function(uri) {
	    "Get details of a contribution given the URL"
	    
	    res <- api_request(uri)
	    return(rjson::fromJSON(res))
	  },
	
		initialize = function(server_uri) {
            "Initialize the client object with the given server URI"
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
			cat(server_uri)
		}
	)
)