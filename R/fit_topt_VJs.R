#' Fitting multiple temperature response curves
#'
#' @param data Dataframe with multiple temperature response curves for Vcmax
#' (maximum rubisco carboxylation capacity in umol m-2 s-1) and Jmax (maximum
#' photosynthetic electron transport to CO2 fixation in umol m-2 s-1).
#' @param group Grouping variable to use, e.g. Plant ID
#' @param varnames Variable names. Reassigns variable names to account for
#' different spellings of Vcmax, Jmax, and Tleaf
#' @param limit_jmax Upper limit to Jmax values for fitting. Defaults to
#' 100,000 umol m-2 s-1 as this is the "nonsense output" from fitaci. Ensures
#' that these points are not fit.
#' @param limit_vcmax Upper limit to Vcmax values for fitting. Defaults to
#' 100,000 umol m-2 s-1.
#' @param ... Arguments to be passed on to minpack.lm::nlsLM via fit_topt_VJ().
#' See ?nlsLM for details.
#' @return fit_topt_VJs fits multiple Vcmax and Jmax temperature responses
#' using the optimum temperature response model from Medlyn et al. 2002.
#' REFERENCE
#' Medlyn BE, Dreyer E, Ellsworth D, Forstreuter M, Harley PC,
#' Kirschbaum MUF, Le Roux X, Montpied P, Strassemeyer J, Walcroft A,
#' Wang K, Loutstau D. 2002. Temperature response of parameters of a
#' biochemically based model of photosynthesis. II. A review of
#' experimental data. Plant Cell Environ 25:1167-1179
#' @export
#' @examples \donttest{
#' #Read in data
#' data <- read.csv(system.file("extdata", "example_2.csv",
#' package = "plantecowrap"), stringsAsFactors = FALSE)
#' #Fit ACi Curves then fit temperature responses
#' fits <- fitacis2(data = data,
#'                  varnames = list(ALEAF = "A",
#'                                  Tleaf = "Tleaf",
#'                                  Ci = "Ci",
#'                                  PPFD = "PPFD",
#'                                  Rd = "Rd",
#'                                  Press = "Press"),
#'                  group1 = "Grouping",
#'                  fitTPU = FALSE,
#'                  fitmethod = "bilinear",
#'                  gm25 = 10000,
#'                  Egm = 0)
#' #Extract coefficients
#' outputs <- acisummary(data, group1 = "Grouping", fits = fits)
#' #Plot curve fits
#' for (i in 1:length(fits)) {
#'   plot(fits[[i]])
#' }
#' #Separate out grouping variable
#' outputs <- separate(outputs, col = "ID", c("Treat", "Block"), sep = "_")
#' #Fit the Topt model from Medlyn et al. 2002 for all individuals
#' #Output is a list of lists for each individual
#' #There is also a fit_topt_VJ for single temperature response
#' #fitting
#' out <- fit_topt_VJs(data = outputs,
#'                     group = "Block", #this grouping variable is for
#'                     #each individual
#'                     varnames = list(Vcmax = "Vcmax",
#'                                     Jmax = "Jmax",
#'                                     Tleaf = "Tleaf"),
#'                     limit_jmax = 100000,
#'                     limit_vcmax = 100000)
#' #Let's get the parameters out into a single data frame
#' pars <- get_t_pars(out)
#' #Let's get the graphs out into a list
#' #You can get a graph using: graph[1]
#' graphs <- get_t_graphs(out)
#' }
fit_topt_VJs <- function(data,
                         group,
                         varnames = list(Vcmax = "Vcmax",
                                         Jmax = "Jmax",
                                         Tleaf = "Tleaf"),
                         limit_jmax = 100000,
                         limit_vcmax = 100000,
                         ...) {
  #Assign group name
  data$group <- data[, group]
  #Split by group
  data <- split(data, data$group)
  #Create output list
  fits <- list()
  #Fit temperature response model
  for (i in 1:length(data)) {
    fits[[i]] <- fit_topt_VJ(data = data[[i]],
                           varnames = varnames,
                           title = names(data[i]),
                           limit_jmax = limit_jmax,
                           limit_vcmax = limit_vcmax,
                           ...)
    #Assign names
    names(fits)[i] <- names(data[i])
  }
  #Return curve fits
  return(fits)
}
