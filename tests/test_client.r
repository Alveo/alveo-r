require(testthat)
require(alveo)

context("Client Tests")

test_that("Can read the configuration file", {
	
	config <- read_config()
	
	expect_that(config$apiKey, is_a("character"))
	expect_that(config$base_url, matches("http.*"))
	expect_that(api_key(), is_a("character"))
	expect_that(cache_dir(), is_a("character")) # maybe also that it names a real directory?
	
})

test_that("Can connect to a server", {
	
	config <- read_config()
	
	client <- RestClient(config$base_url)
	
	# we get some kind of string back from the server
	expect_that(client$get_api_version() == "", is_false())
	
	expect_that(client$get_annotation_context(), equals(''))
})