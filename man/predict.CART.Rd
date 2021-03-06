% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cart.R
\name{predict.CART}
\alias{predict.CART}
\title{predict.CART}
\usage{
\method{predict}{CART}(object, seed = 1232, newdata = object$model, ...)
}
\arguments{
\item{object}{A \code{CART} object.}

\item{seed}{A random number seed to ensure stability of predictions.}

\item{newdata}{Optionally, a data frame including the variables used to fit the model.
If omitted, the \code{data} supplied to \code{CART()} is used before any filtering.}

\item{...}{Extra parameters. Currently not used.}
}
\description{
Predicts values for numeric outcomes and group membership for categories based on \code{newdata}
and a fitted CART \code{object}.  A value (which may be NA) is returned for every instance
in \code{newdata} including those with missing data. NA is returned for cases with unfitted factor levels.
}
