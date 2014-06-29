Alveo R Library
=======

This is the main repository for the R library to interact with the Alveo API

Documentation for this library can be found [here](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RLibrary.md)

Binary installation files are provided for various platforms:

| Package | Mac | Linux (Centos) | Windows |
| ------  | --- | -------------- | ------- |
| alveo   | [alveo_1.0.1.tgz](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RPackages/alveo_1.0.1.tgz) | [alveo_1.0.1_R_x86_64-redhat-linux-gnu.tar.gz](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RPackages/alveo_1.0.1_R_x86_64-redhat-linux-gnu.tar.gz) | [alveo_1.0.1.zip](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RPackages/alveo_1.0.1.zip) |

Older versions of the binaries can be found in dated directories at [this page](https://github.com/IntersectAustralia/hcsvlab-docs/tree/master/RPackages)

Example Usage:

	client <- RestClient(server_uri="app.alveo.edu.au")
	client$get_api_version()

	results <- client$search_metadata("music")
	client$create_item_list(results$items, "Item List 1")
	client$get_item_lists()

	item_list <- client$get_item_list_by_id(1)
	item_list$download("/home/user/R")
	item_list$get_items()
	item_list$get_item_documents()
	item_list$get_segment_list()

	item <- item_list$get_item(1)
	item$get_metadata()
	item$get_indexable_text()
	item$get_documents()
	item$get_annotations(type="phonetic", label="h")

	document <- item$get_document(1)
	document$download("/home/user/R")


### Related Packages ###

We also have two other packages which can be used with data from Alveo. These are the wrassp and emuSX libraries. 
### Installation

Download the appropriate binary from the list below to your machine.

| Package | Mac | Linux (Centos) | Windows |
| ------  | --- | -------------- | ------- |
| wrassp | [wrassp_0.0.3.tgz](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RPackages/wrassp_0.0.3.tgz) | [wrassp_0.0.3_R_x86_64-redhat-linux-gnu.tar.gz](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RPackages/wrassp_0.0.3_R_x86_64-redhat-linux-gnu.tar.gz) | [wrassp_0.0.3.zip](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RPackages/wrassp_0.0.3.zip) |
| emuSX | [emuSX_0.0.8.tgz](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RPackages/emuSX_0.0.8.tgz) | [emuSX_0.0.8_R_x86_64-redhat-linux-gnu.tar.gz](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RPackages/emuSX_0.0.8_R_x86_64-redhat-linux-gnu.tar.gz) | [emuSX_0.0.8.zip](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RPackages/emuSX_0.0.8.zip) |
| websockets | [websockets_1.1.7.tar.gz](http://cran.r-project.org/src/contrib/Archive/websockets/websockets_1.1.7.tar.gz) | [websockets_1.1.7.tar.gz](http://cran.r-project.org/src/contrib/Archive/websockets/websockets_1.1.7.tar.gz) | [websockets_1.1.7.tar.gz](http://cran.r-project.org/src/contrib/Archive/websockets/websockets_1.1.7.tar.gz) |
Then inside R run the following commands:

    # install dependencies
    install.packages("rjson")
    install.packages("RCurl")
    install.packages('testthat')
    install.packages("base64enc")
    install.packages("caTools")
    install.packages("uuid")
    install.packages("stringr")
    
    # install package. it'll pick binary automatically if it's not a source package
    install.packages("<path to binary>", repos = NULL, type = 'source')
    library(emuSX)
    
where `<path to binary>` is the path to the binary downloaded above
    
### Testing

Tests are written using the 'testthat' package and are in the tests directory.  To run the tests use the 'devtools' library and run the following commands in an R session in the project directory:

    library(testthat)
    library(devtools)
    
    test()

the test can be re-run after changes are made without re-starting the R session (devtools reloads the module).  

