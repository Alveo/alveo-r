Document <- setRefClass("Document",

	fields = list(
		uri = "character"
	),

	methods = list(

		get_content = function() {
			res <- api_request(uri)
			return(res)
		},

		download = function(destination) {
			content <- get_content()

			if(!file.exists(destination)) {
				dir.create(destination)
			}

			basename <- basename(uri)
			filename <- file.path(destination, basename)

			write(content, file=filename)

			return(filename)
		},

		show = function() {
			cat("URI: \n")
			methods::show(uri)
		}
	)
)