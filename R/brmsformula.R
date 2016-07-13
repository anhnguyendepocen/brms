#' Set up a model formula for use in the \pkg{brms} package
#' 
#' Set up a model formula for use in the \pkg{brms} package
#' allowing to define additive multilevel models for all parameters
#' of the assumed response distribution.
#' 
#' @aliases bf
#' 
#' @param formula An object of class \code{formula} 
#'   (or one that can be coerced to that class): 
#'   a symbolic description of the model to be fitted. 
#'   The details of model specification are given under 'Details'.
#' @param ... Additional \code{formula} objects to specify 
#'   predictors of special model parts and auxiliary parameters. 
#'   Formulas can either be named directly or contain
#'   names on their left-hand side. Currently, the following
#'   names are accepted: 
#'   \code{sigma} (residual standard deviation of
#'   the \code{gaussian} and \code{student} families);
#'   \code{shape} (shape parameter of the \code{Gamma},
#'   \code{weibull}, \code{negbinomial} and related
#'   zero-inflated / hurdle families); \code{nu}
#'   (degrees of freedom parameter of the \code{student} family);
#'   \code{phi} (precision parameter of the \code{beta} 
#'   and \code{zero_inflated_beta} families).
#'   All auxiliary parameters are modeled 
#'   on the log-scale to ensure their positivity after
#'   back transformation.
#' @inheritParams brm
#' 
#' @return An object of class \code{brmsformula}, which inherits
#'  from class \code{formula} but contains additional attributes.
#'   
#' @details The \code{formula} argument accepts formulae of the following syntax:
#'   
#'   \code{response | addition ~ fixed + (random | group)} 
#'   
#'   The \code{fixed} term contains effects that are assumend to be the 
#'   same across obervations. We call them 'population-level' effects
#'   or (adopting frequentist vocabulary) 'fixed' effects. The optional
#'   \code{random} terms may contain effects that are assumed to vary
#'   accross grouping variables specified in \code{group}. We
#'   call them 'group-level' effects or (adopting frequentist 
#'   vocabulary) 'random' effects, although the latter name is misleading
#'   in a Bayesian context (for more details type \code{vignette("brms")}).
#'   Multiple grouping factors each with multiple group-level effects 
#'   are possible. Instead of | you may use || in grouping terms
#'   to prevent correlations from being modeled. With three exceptions, 
#'   this is basically \code{lme4} syntax. 
#'   
#'   First, smoothing terms can modeled using the \code{\link[mgcv:s]{s}}
#'   and \code{\link[mgcv:t2]{t2}} functions of the \pkg{mgcv} package 
#'   in the \code{fixed} part of the model formula.
#'   This allows to fit generalized additive mixed models (GAMMs) with \pkg{brms}. 
#'   The implementation is similar to that used in the \pkg{gamm4} package.
#'   For more details on this model class see \code{\link[mgcv:gam]{gam}} 
#'   and \code{\link[mgcv:gamm]{gamm}}.
#'   
#'   Second, \code{fixed} may contain two non-standard types
#'   of population-level effects namely monotonic and category specific effects,
#'   which can be specified using terms of the form \code{monotonic(<predictors>)} 
#'   and \code{cse(<predictors>)} respectively. The latter can only be applied in
#'   ordinal models and is explained in more detail in the package's vignette
#'   (type \code{vignette("brms")}). The former effect type is explained here.
#'   A monotonic predictor must either be integer valued or an ordered factor, 
#'   which is the first difference to an ordinary continuous predictor. 
#'   More importantly, predictor categories (or integers) are not assumend to be 
#'   equidistant with respect to their effect on the response variable. 
#'   Instead, the distance between adjacent predictor categories (or integers) 
#'   is estimated from the data and may vary across categories. 
#'   This is realized by parameterizing as follows: 
#'   One parameter takes care of the direction and size of the effect similar 
#'   to an ordinary regression parameter, while an additional parameter vector 
#'   estimates the normalized distances between consecutive predictor categories.     
#'   A main application of monotonic effects are ordinal predictors that
#'   can this way be modeled without (falsely) treating them as continuous
#'   or as unordered categorical predictors.
#'   
#'   The third exception is the optional \code{addition} term, which may contain 
#'   multiple terms of the form \code{fun(variable)} seperated by \code{+} each 
#'   providing special information on the response variable. \code{fun} can be 
#'   replaced with either \code{se}, \code{weights}, \code{disp}, \code{trials},
#'   \code{cat}, \code{cens}, or \code{trunc}. Their meanings are explained below. 
#'   
#'   For families \code{gaussian}, \code{student}, and \code{cauchy} it is 
#'   possible to specify standard errors of the observation, thus allowing 
#'   to perform meta-analysis. Suppose that the variable \code{yi} contains 
#'   the effect sizes from the studies and \code{sei} the corresponding 
#'   standard errors. Then, fixed and random effects meta-analyses can 
#'   be conducted using the formulae \code{yi | se(sei) ~ 1} and 
#'   \code{yi | se(sei) ~ 1 + (1|study)}, respectively, where 
#'   \code{study} is a variable uniquely identifying every study.
#'   If desired, meta-regression can be performed via 
#'   \code{yi | se(sei) ~ 1 + mod1 + mod2 + (1|study)} 
#'   or \cr \code{yi | se(sei) ~ 1 + mod1 + mod2 + (1 + mod1 + mod2|study)}, where
#'   \code{mod1} and \code{mod2} represent moderator variables. 
#'   
#'   For all families, weighted regression may be performed using
#'   \code{weights} in the addition part. Internally, this is 
#'   implemented by multiplying the log-posterior values of each 
#'   observation by their corresponding weights.
#'   Suppose that variable \code{wei} contains the weights 
#'   and that \code{yi} is the response variable. 
#'   Then, formula \code{yi | weights(wei) ~ predictors} 
#'   implements a weighted regression. 
#'   
#'   The addition argument \code{disp} (short for dispersion) serves a
#'   similar purpose than \code{weight}. However, it has a different 
#'   implementation and is less general as it is only usable for the
#'   families \code{gaussian}, \code{student}, \code{cauchy},
#'   \code{lognormal}, \code{Gamma}, \code{weibull}, and \code{negbinomial}.
#'   For the former four families, the residual standard deviation 
#'   \code{sigma} is multiplied by the values given in 
#'   \code{disp}, so that higher values lead to lower weights.
#'   Contrariwise, for the latter three families, the parameter \code{shape}
#'   is multiplied by the values given in \code{disp}. As \code{shape}
#'   can be understood as a precision parameter (inverse of the variance),
#'   higher values will lead to higher weights in this case.
#'   
#'   For families \code{binomial} and \code{zero_inflated_binomial}, 
#'   addition should contain a variable indicating the number of trials 
#'   underlying each observation. In \code{lme4} syntax, we may write for instance 
#'   \code{cbind(success, n - success)}, which is equivalent
#'   to \code{success | trials(n)} in \code{brms} syntax. If the number of trials
#'   is constant across all observation (say \code{10}), 
#'   we may also write \code{success | trials(10)}. 
#'   
#'   For family \code{categorical} and all ordinal families, 
#'   \code{addition} may contain a term \code{cat(number)} to
#'   specify the number categories (e.g, \code{cat(7)}). 
#'   If not given, the number of categories is calculated from the data.
#'   
#'   With the expection of \code{categorical} and ordinal families, 
#'   left and right censoring can be modeled through 
#'   \code{yi | cens(censored) ~ predictors}.
#'   The censoring variable (named \code{censored} in this example) should 
#'   contain the values \code{'left'}, \code{'none'}, and \code{'right'}  
#'   (or equivalenty -1, 0, and 1) to indicate that the corresponding observation is 
#'   left censored, not censored, or right censored. 
#'   
#'   With the expection of \code{categorical} and ordinal families, the response 
#'   distribution can be truncated using the \code{trunc} function in the addition part.
#'   If the response variable is truncated between, say, 0 and 100, we can specify this via
#'   \code{yi | trunc(lb = 0, ub = 100) ~ predictors}. Defining only one of the two arguments 
#'   in \code{trunc} leads to one-sided truncation.
#' 
#'   Mutiple \code{addition} terms may be specified at the same time using 
#'   the \code{+} operator, for instance \code{formula = yi | se(sei) + cens(censored) ~ 1} 
#'   for a censored meta-analytic model. \cr
#'   
#'   For families \code{gaussian}, \code{student}, and \code{cauchy} 
#'   multivariate models may be specified using \code{cbind} notation. 
#'   Suppose that \code{y1} and \code{y2} are response variables 
#'   and \code{x} is a predictor.
#'   Then \code{cbind(y1,y2) ~ x} specifies a multivariate model, 
#'   where \code{x} has the same effect on \code{y1} and \code{y2}.
#'   To indicate different effects on each response variable, 
#'   the factor \code{trait} (which is reserved in multivariate models) 
#'   can be used as an additional predictor. 
#'   For instance, \code{cbind(y1,y2) ~ 0 + trait + x:trait} leads to seperate effects
#'   of \code{x} on \code{y1} and \code{y2} as well as to separate intercepts. 
#'   In this case, \code{trait} has two levels, namely \code{"y1"} and \code{"y2"}. 
#'   It may also be used within random effects terms, both as grouping factor or 
#'   as random effect within a grouping factor. Note that variable \code{trait} is generated 
#'   internally and may not be specified in the data passed to \code{brm}. \cr
#'   
#'   As of \pkg{brms} 0.9.0, categorical models use the same syntax as multivariate
#'   models, but in this case, \code{trait} differentiates between the response 
#'   categories. As in most other implementations of categorical models,
#'   values of one category are fixed to identify the model. 
#'   Accordingly, \code{trait} has \code{K - 1} levels, 
#'   where \code{K} is the number of categories. 
#'   Usually, it makes most sense to use terms of the structure
#'   \code{0 + trait + trait:(<predictors>)}.
#'   
#'   Zero-inflated and hurdle families are bivariate and also make use 
#'   of the special internal variable \code{trait} having two levels in this case. 
#'   However, only the actual response must be specified in \code{formula}, 
#'   as the second response variable used for the zero-inflation / hurdle
#'   (ZIH) part is internally generated.
#'   A \code{formula} for this type of models may, for instance, look like this: \cr
#'   \code{y ~ 0 + trait + trait:(x1 + x2) + (0 + trait | g)}. 
#'   In this example, the predictors \code{x1} and \code{x1} influence the ZIH part 
#'   differentlythan the actual response part as indicated by their 
#'   interaction with \code{trait}.
#'   In addition, a group-level effect of \code{trait} was added while 
#'   the group-level intercept was removed leading to the estimation of 
#'   two effects, one for the ZIH part and one for the actual response. 
#'   In the example above, the correlation between the two effects
#'   will also be estimated.
#'   Sometimes, predictors should only influence the ZIH part
#'   but not the actual response (or vice versa). As this cannot be modeled
#'   with the \code{trait} variable, two other internally generated and 
#'   reserved (numeric) variables, namely \code{main} and \code{spec}, are supported.
#'   \code{main} is \code{1} for the response part and \code{0} for the
#'   ZIH part of the model. For \code{spec} it is the other way round.
#'   Suppose that \code{x1} should only influence the actual response,
#'   and \code{x2} only the ZIH process. We can write this as follows:
#'   \code{formula = y ~ 0 + main + spec + main:x1 + spec:x2}. 
#'   The main effects of \code{main} or \code{spec} serve as intercepts,
#'   while the interaction terms \code{main:x1} and \code{spec:x2} ensure
#'   that \code{x1} and \code{x2} only predict one part of the model, respectively.
#'   Please note that in \pkg{brms} the ZIH part models the probability 
#'   of the response being zero, while in some other packages it models 
#'   the probability of the response being non-zero. Thus, coefficients 
#'   of the ZIH part may have opposite signs depending on which package 
#'   you use.
#'   
#'   Using the same syntax as for zero-inflated and hurdle models, it is
#'   possible to specify multiplicative effects in family \code{bernoulli}
#'   (make sure to set argument \code{type} to \code{"2PL"}; 
#'   see \code{\link[brms:brmsfamily]{brmsfamily}} for more details).
#'   In Item Response Theory (IRT), these models are known as 2PL models.
#'   Suppose that we have the variables \code{item} and \code{person} and
#'   want to model fixed effects for items and random effects for persons.
#'   The discriminality (multiplicative effect) should depend only on the items. 
#'   We can specify this by setting
#'   \code{formula = response ~ 0 + (main + spec):item + (0 + main|person)}. 
#'   The random term \code{0 + main} ensures that \code{person} does 
#'   not influence discriminalities. Of course it is possible
#'   to predict only discriminalities by using
#'   variable \code{spec} in the model formulation. 
#'   To identify the model, multiplicative effects are estimated on the log scale. 
#'   In addition, we strongly recommend setting proper priors 
#'   on fixed effects in this case to increase sampling efficiency 
#'   (for details on priors see \code{\link[brms:set_prior]{set_prior}}).     
#'   
#'   \bold{Parameterization of the population-level intercept}
#'   
#'   The population-level intercept (if incorporated) is estimated separately 
#'   and not as part of population-level parameter vector \code{b}. 
#'   This has the side effect that priors on the intercept 
#'   also have to be specified separately
#'   (see \code{\link[brms:set_prior]{set_prior}} for more details).
#'   Furthermore, to increase sampling efficiency, the fixed effects 
#'   design matrix \code{X} is centered around its column means 
#'   \code{X_means} if the intercept is incorporated. 
#'   This leads to a temporary bias in the intercept equal to 
#'   \code{<X_means, b>}, where \code{<,>} is the scalar product. 
#'   The bias is corrected after fitting the model, but be aware 
#'   that you are effectively defining a prior on the temporary
#'   intercept of the centered design matrix not on the real intercept.
#'   
#'   This behavior can be avoided by using the reserved 
#'   (and internally generated) variable \code{intercept}. 
#'   Instead of \code{y ~ x}, you may write
#'   \code{y ~ 0 + intercept + x}. This way, priors can be
#'   defined on the real intercept, directly. In addition,
#'   the intercept is just treated as an ordinary fixed effect
#'   and thus priors defined on \code{b} will also apply to it. 
#'   Note that this parameterization may be a bit less efficient
#'   than the default parameterization discussed above.  
#'   
#'   \bold{Formula syntax for non-linear multilevel models}
#'   
#'   Using the \code{nonlinear} argument, it is possible to specify
#'   non-linear models in \pkg{brms}. Contrary to what the name might suggest,
#'   \code{nonlinear} should not contain the non-linear model itself
#'   but rather information on the non-linear parameters. 
#'   The non-linear model will just be specified within the \code{formula}
#'   argument. Suppose, that we want to predict the response \code{y}
#'   through the predictor \code{x}, where \code{x} is linked to \code{y}
#'   through \code{y = alpha - beta * lambda^x}, with parameters
#'   \code{alpha}, \code{beta}, and \code{lambda}. This is certainly a
#'   non-linear model being defined via
#'   \code{formula = y ~ alpha - beta * lambda^x} (addition arguments 
#'   can be added in the same way as for ordinary formulas).
#'   Now we have to tell \pkg{brms} the names of the non-linear parameters 
#'   and specfiy a (linear mixed) model for each of them using the \code{nonlinear}
#'   argument. Let's say we just want to estimate those three parameters
#'   with no further covariates or random effects. Then we can write
#'   \code{nonlinear = alpha + beta + lambda ~ 1} or equivalently
#'   (and more flexible) \code{nonlinear = list(alpha ~ 1, beta ~ 1, lambda ~ 1)}. 
#'   This can, of course, be extended. If we have another predictor \code{z} and 
#'   observations nested within the grouping factor \code{g}, we may write for 
#'   instance \cr \code{nonlinear = list(alpha ~ 1, beta ~ 1 + z + (1|g), lambda ~ 1)}.
#'   The formula syntax described above applies here as well.
#'   In this example, we are using \code{z} and \code{g} only for the 
#'   prediction of \code{beta}, but we might also use them for the other
#'   non-linear parameters (provided that the resulting model is still 
#'   scientifically reasonable). 
#'   
#'   Non-linear models may not be uniquely identified and / or show bad convergence.
#'   For this reason it is mandatory to specify priors on the non-linear parameters.
#'   For instructions on how to do that, see \code{\link[brms:set_prior]{set_prior}}.
#'   
#'   \bold{Formula syntax for predicting auxiliary parameters}
#'   
#'   It is also possible to predict auxiliary parameters of the response
#'   distribution such as the residual standard deviation \code{sigma} 
#'   in gaussian models. The syntax closely resembles that of a non-linear 
#'   parameter, for instance: \code{sigma ~ x + s(z) + (1+x|g)}.
#' 
#' @examples 
#' # multilevel model with smoothing terms
#' brmsformula(y ~ x1*x2 + s(z) + (1+x1|1) + (1|g2))
#' 
#' # additionally predict 'sigma'
#' brmsformula(y ~ x1*x2 + s(z) + (1+x1|1) + (1|g2), 
#'             sigma ~ x1 + (1|g2))
#'             
#' # use the shorter alias 'bf'
#' (formula1 <- brmsformula(y ~ x + (x|g)))
#' (formula2 <- bf(y ~ x + (x|g)))
#' # will be TRUE
#' identical(formula1, formula2)
#' 
#' # incorporate censoring
#' bf(y | cens(censor_variable) ~ predictors)
#' 
#' # define a non-linear model
#' bf(y ~ a1 - a2^x, nonlinear = list(a1 ~ x, a2 ~ x + (x|g)))
#' 
#' # define a multivariate model
#' bf(cbind(y1, y2) ~ 0 + trait + trait:(x*z) + (0+trait|g))
#' 
#' # define a zero-inflated or hurdle model
#' bf(y ~ 0 + main + spec + main:(x*z) + spec:x + (0+main+spec|g))
#' 
#' # specify a predictor as monotonic
#' bf(y ~ mono(x) + more_predictors)
#' 
#' # specify a predictor as category specific
#' # for ordinal models only
#' bf(y ~ cse(x) + more_predictors)
#' 
#' @export
brmsformula <- function(formula, ..., nonlinear = NULL) {
  # parse and validate dots arguments
  dots <- list(...)
  parnames <- names(dots)
  if (is.null(parnames)) {
    parnames <- rep("", length(dots))
  }
  for (i in seq_along(dots)) {
    dots[[i]] <- as.formula(dots[[i]])
    if (length(dots[[i]]) == 3L && !nchar(parnames[i])) {
      resp_par <- all.vars(dots[[i]][[2]])
      if (length(resp_par) != 1L) {
        stop("LHS of additional formulas must contain exactly one variable.",
             call. = FALSE)
      }
      parnames[i] <- resp_par
    }
    if (!is.null(attr(terms(dots[[i]]), "offset"))) {
      stop("Offsets are currently not allowed.", call. = FALSE)
    }
    dots[[i]] <- rhs(dots[[i]])
  }
  names(dots) <- parnames
  if (any(!nchar(names(dots)))) {
    stop("Function 'bf' requires named arguments.", call. = FALSE)
  }
  invalid_names <- setdiff(names(dots), auxpars())
  if (length(invalid_names)) {
    stop("The following argument names were invalid: ",
         paste(invalid_names, collapse = ", "), call. = FALSE)
  }
  # add attributes to formula
  if (is.logical(attr(formula, "nonlinear"))) {
    # In brms < 0.10.0 the nonlinear attribute was used differently
    attr(formula, "nonlinear") <- NULL
  }
  auxpars <- auxpars(incl_nl = TRUE)
  old_att <- rmNULL(attributes(formula)[auxpars])
  formula <- as.formula(formula)
  nonlinear <- nonlinear2list(nonlinear)
  new_att <- rmNULL(c(nlist(nonlinear), dots))
  dupl_args <- intersect(names(new_att), names(old_att))
  if (length(dupl_args)) {
    warning("Duplicated definitions of arguments ", 
            paste0("'", dupl_args, "'", collapse = ", "),
            "\nIgnoring definitions outside the formula",
            call. = FALSE)
  }
  null_pars <- setdiff(auxpars, names(old_att))
  new_pars <- intersect(names(new_att), null_pars)
  att <- c(old_att, new_att[new_pars])
  attributes(formula)[names(att)] <- att
  class(formula) <- c("brmsformula", "formula")
  formula
}

#' @export
bf <- function(formula, ..., nonlinear = NULL) {
  # alias of brmsformula
  brmsformula(formula, ..., nonlinear = nonlinear)
}