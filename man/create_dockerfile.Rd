% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/docker.R
\name{create_dockerfile}
\alias{create_dockerfile}
\title{Dockerfile}
\usage{
create_dockerfile(port, host = "0.0.0.0", file_path)
}
\arguments{
\item{port, host}{Port and host to serve the application.}

\item{file_path}{String. Path to file to write to.}
}
\value{
\code{NULL} (invisibly)
}
\description{
Create the dockerfile required to run the application.
The dockerfile created will install packages from
RStudio Public Package Manager
which comes with pre-built binaries
that much improve the speed of building of Dockerfiles.
}
\details{
Reads the \code{DESCRIPTION} file of the project to produce the \code{Dockerfile}.
}
\examples{
if (interactive()) {
  create_dockerfile(port = 5000L, host = "0.0.0.0", file_path = tempfile())
  # create_dockerfile(port = 5000L, host = "0.0.0.0", file_path = "Dockerfile")
}

}
