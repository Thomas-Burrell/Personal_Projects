package.name <- "UnceRtainty"
package.dir <- paste("C:/Users/affes/OneDrive/Documents/UVA SDS Fall 2023/DS 6030/",package.name,sep="")
setwd(package.dir)
### --- Use Roxygenise to generate .RD files from my comments
library(roxygen2)
roxygenise(package.dir=package.dir)
system(command=paste("R CMD INSTALL '",package.dir,"'",sep=""))
