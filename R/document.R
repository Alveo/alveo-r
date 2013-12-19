Document <- setRefClass("Document",

	fields = list(
		uri = "character",
		type = "character",
		size = "character"
	),

	methods = list(

		get_content = function() {
			header <- get_header_contents()

			res <- getURLContent(uri, httpheader=header)
			return(res)
		},

		download = function(destination) {
			content <- get_content()

			if(!file.exists(destination)) {
				dir.create(destination)
			}

			basename <- basename(uri)
			filename <- file.path(destination, basename)

			writeBin(as.vector(content), filename)

			return(filename)
		},

		show = function() {
			cat("URI: \n")
			methods::show(uri)
			cat("Type: \n")
			methods::show(type)
			cat("Size: \n")
			methods::show(size)
		}
	)
)