Item <- setRefClass("Item",

	fields = list(
		id = "character",
		uri = "character"
	),

	methods = list(

		get_metadata = function() {
			res <- api_request(uri)
			return(fromJSON(res)$metadata)
		},

		get_all_metadata = function() {
			res <- api_request(uri)
			return(fromJSON(res))
		},

		get_indexable_text = function() {
			metadata <- get_all_metadata()
			if(!is.null(metadata$primary_text_url) && metadata$primary_text_url != "No primary text found") {
				res <- api_request(metadata$primary_text_url)
				return(res)
			}
			else {
				return("")
			}
		},

		get_documents = function() {
			metadata <- get_all_metadata()
			return(metadata$documents)
		},

		get_document = function(index) {
			metadata <- get_all_metadata()
			if(index > length(metadata$documents) || index < 1) {
				stop('index out of bounds')
			}
			doc <- metadata$documents[[index]]
			return(Document(uri=doc$url, type=as.character(doc$`dc:type`), size=as.character(doc$size)))
		},

		get_annotations = function(type = NULL, label = NULL) {
			annotations_url <- "/annotations"
			if(!is.null(type) && !is.null(label)) {
				annotations_url <- paste(annotations_url, "?type=", type, "&label=", label, sep="")
			}
			else if(!is.null(type) && is.null(label)) {
				annotations_url <- paste(annotations_url, "?type=", type, sep="")
			}
			else if(is.null(type) && !is.null(label)) {
				annotations_url <- paste(annotations_url, "?label=", label, sep="")
			}

			res <- api_request(paste(uri, annotations_url, sep=""))
			return(fromJSON(res))
		},

		show = function() {
			cat("ID: \n")
			methods::show(id)
			cat("URI: \n")
			methods::show(uri)
		}
	)
)