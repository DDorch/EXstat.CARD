# Copyright 2020      Ivan Horner (ivan.horner@irstea.fr)*1,
#           2022-2025 Louis, Héraut <louis.heraut@inrae.fr>*2
#
# *1 IRSTEA, France
# *2 INRAE, UR RiverLy, Villeurbanne, France
#
# This file is part of CARD R package.
#
# CARD R package is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# CARD R package is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CARD R package.
# If not, see <https://www.gnu.org/licenses/>.


#  ___  _
# | __|| | ___ __ __ __
# | _| | |/ _ \\ V  V / 
# |_|  |_|\___/ \_/\_/
#     _                   _    _            
#  __| | _  _  _ _  __ _ | |_ (_) ___  _ _  
# / _` || || || '_|/ _` ||  _|| |/ _ \| ' \ 
# \__,_| \_,_||_|  \__,_| \__||_|\___/|_||_|
#
#  __  _  _  _ _ __ __ ___ 
# / _|| || || '_|\ V // -_)
# \__| \_,_||_|   \_/ \___| __________________________________________
## 1. QUANTILE _______________________________________________________
#' @title compute_Qp 
#' @description description
#' @param Q discharge
#' @seealso ref
#' @export
#' @md
compute_Qp = function (Q, p) {
    Qp = quantile(Q[!is.na(Q)], 1-p, names=FALSE)
    return (Qp)
}


## 2. USE ____________________________________________________________
### 2.1. Frequency ___________________________________________________
#' @title compute_fAp
#' @description description
#' @param Q discharge
#' @seealso ref
#' @export
#' @md
compute_fAp = function (Q, lowLim) {
    lowLimRLE = rle(lowLim[!is.na(lowLim)])
    lowLim = lowLimRLE$values[which.max(lowLimRLE$lengths)]
    n = sum(as.numeric(Q[!is.na(Q)] > lowLim))
    N = length(Q)
    fA = n/N # jour par an
    return (fA)
}

### 2.2. Slope _______________________________________________________
#' @title fdc_slope
#' @description Compute the mid-segment flow duration curve slope
#' @param Q Streamflow vector
#' @param p A length 2 numeric vector containing the exceedance
#' probability that define the of the mid-segment
#' @return Mid-segment low duration curve slope
#' @export
fdc_slope = function(Q, p=c(0.33, 0.66)) {
    Qp = compute_Qp(Q, p=p)
    res = - (log10(Qp[1L]) - log10(Qp[2L])) / diff(p)
    return (res)
}

### 2.3. Curve _______________________________________________________
#' @title fdc_values
#' @description Given a vector of streamflow values, computes a
#' data.frame with two columns : a 'p' column containing the
#' probability of exceedance and a 'Q' column containing the
#' corresponding streamflow values. Two methods can be used : simply
#' sorting the data (not recommended) or using the quantile function.
#' @param Q Streamflow vector
#' @param n number of rows in the resulting data.frame (should be
#' smaller than the length of 'Q'.
#' @param sort logical. Should the sort function be used instead
#' of the quantile function ?
#' @param na.rm logical. Should the missing values be ignored ? (must
#' be TRUE if the quantile function is used !)
#' @return res
#' @export
compute_FDC = function (Q, n=1000, sort=FALSE, isNormLaw=FALSE, na.rm=TRUE) {
    if (na.rm) {
        Q = Q[!is.na(Q)]
    }
    if (sort) {
        m = length(Q)
        pfdc = 1-1:m/m
        Qfdc = sort(Q, na.last=ifelse(na.rm, NA, FALSE))
    } else {
        if (n > length(Q)) {
            warning("'n' is larger than the number of values in 'Q'!")
        }
        if (isNormLaw) {
            pfdc = pnorm(seq(-3, 3, length.out=n))
        } else {
            pfdc = seq(0, 1, length.out=n)
        }
        Qfdc = compute_Qp(Q, p=pfdc)
    }
    res = dplyr::tibble(p=pfdc, Q=Qfdc)
    return(res)
}


#' @title compute_FDC_p 
#' @description description
#' @param Q discharge
#' @seealso ref
#' @export
#' @md
compute_FDC_p = function (n=1000, sort=FALSE, isNormLaw=FALSE, na.rm=TRUE) {
    if (sort) {
        pfdc = 1-1:n/n
    } else {
        if (isNormLaw) {
            pfdc = pnorm(seq(-3, 3, length.out=n))
        } else {
            pfdc = seq(0, 1, length.out=n)
        }
    }
    return (pfdc)
}

#' @title compute_FDC_Q
#' @description description
#' @param Q discharge
#' @seealso ref
#' @export
#' @md
compute_FDC_Q = function (Q, n=1000, sort=FALSE, isNormLaw=FALSE, na.rm=TRUE) {
    if (na.rm) {
        Q = Q[!is.na(Q)]
    }
    if (sort) {
        m = length(Q)
        pfdc = 1-1:m/m
        Qfdc = sort(Q, na.last=ifelse(na.rm, NA, FALSE))
    } else {
        if (n > length(Q)) {
            warning("'n' is larger than the number of values in 'Q'!")
        }
        if (isNormLaw) {
            pfdc = pnorm(seq(-3, 3, length.out=n))
        } else {
            pfdc = seq(0, 1, length.out=n)
        }
        Qfdc = compute_Qp(Q, p=pfdc)
    }
    return (Qfdc)
}
