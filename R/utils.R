#' Browse App
#'
#' Browses the application, if RStudio available uses pane.
#'
#' @param open Whether to open the app.
#' @param url URL to browse.
#'
#' @noRd
#' @keywords internal
browse_ambiorix <- function(open, url) {
  if (!open) {
    return()
  }

  viewer <- getOption("viewer", browseURL)

  x <- tryCatch(
    viewer(url),
    error = function(e) e
  )

  if (inherits(x, "error")) {
    message("Unable to open browser, please open manually.")
  }

  invisible()
}

`%response%` <- function(lhs, rhs) {
  if (is.null(lhs)) {
    return(rhs)
  }
  if (!inherits(lhs, "ambiorixResponse")) {
    return(rhs)
  }
  return(lhs)
}

`%error%` <- function(lhs, rhs) {
  if (is.null(lhs)) {
    return(rhs)
  }
  return(lhs)
}

#' Remove Extensions
#'
#' Remove extensions from files.
#'
#' @noRd
#' @keywords internal
remove_extensions <- function(files) {
  tools::file_path_sans_ext(files)
}

#' Checks if Package is Installed
#'
#' Checks if a package is installed, stops if not.
#'
#' @param pkg Package to check.
#'
#' @noRd
#' @keywords internal
check_installed <- function(pkg) {
  has_it <- base::requireNamespace(pkg, quietly = TRUE)

  if (!has_it) {
    stop(sprintf("This function requires the package {%s}", pkg), call. = FALSE)
  }
}

#' Retrieve the Port for Server Binding
#'
#' Determines the appropriate port for the server, following a
#' specific order of precedence.
#'
#' @param host String. The host address to bind to when selecting a random port.
#' @param port Integer. An optional input port, provided by the user.
#' @details The port to use is resolved in the following order of precedence:
#' 1. Forced Port Option: Typically used by Belgic, the load balancer. If
#'   the `ambiorix.port.force` R option is specified, this port is returned.
#'   This option should not be altered during development.
#' 2. `AMBIORIX_PORT` environment variable
#' 3. `port` argument.
#' 4. `SHINY_PORT` environment variable.
#' 5. Random port.
#'
#' @return Integer. Port value to bind the server.
#'
#' @noRd
#' @keywords internal
get_port <- function(host, port = NULL) {
  # we need to override the port if the load balancer
  # is running. This should NOT be set by a dev
  # this ensures we can overwrite
  forced <- getOption("ambiorix.port.force")
  if (!is.null(forced)) {
    return(forced)
  }

  has_ints_only <- function(x) !grepl(pattern = "\\D", x = x)
  is_valid_port <- function(x) {
    !is.null(x) && !identical(x, "") && has_ints_only(x)
  }

  ambiorix_port <- Sys.getenv("AMBIORIX_PORT")
  if (is_valid_port(ambiorix_port)) {
    return(as.integer(ambiorix_port))
  }

  if (is_valid_port(port)) {
    return(as.integer(port))
  }

  shiny_port <- Sys.getenv("SHINY_PORT")
  if (is_valid_port(shiny_port)) {
    return(as.integer(shiny_port))
  }

  httpuv::randomPort(host = host)
}

#' Silent readLines
#'
#' Avoids EOF warnings.
#'
#' @param ... Passed to [readLines()]:
#'
#' @keywords internal
#' @noRd
read_lines <- function(...) {
  readLines(..., warn = FALSE)
}

#' Read file from disk or cache
#'
#' @param path Path to file.
#'
#' @keywords internal
#' @noRd
read_lines_cached <- function(path) {
  if (!.globals$cache_tmpls) {
    return(read_lines(path))
  }

  if (length(.cache_tmpls[[path]]) > 0L) {
    return(.cache_tmpls[[path]])
  }

  content <- read_lines(path)
  .cache_tmpls[[path]] <- content
  return(content)
}
