\name{get_segment_list}
\alias{get_segment_list}
\title{Make an Emu segment list from items in an item list}
\usage{
get_segment_list(type = "", label = "")
}
\arguments{
  \item{type}{Type of segments to extract}

  \item{label}{Value of labels to extract}
}
\value{
An Emu segment list
}
\description{
Traverses through each item in the item list and gets
segment information for each item (if annotation set exists
for item) in order to produce a segment list.
}
\examples{
#   item_list = client$get_item_list('http://hcsvlab.intersect.org.au/item_lists/10.json')
#   segment_list = item_list$get_segment_list()
}
\author{
Matt Hillman
}

