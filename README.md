
<!-- README.md is generated from README.Rmd. Please edit that file -->
sfgbuilder
==========

The goal of sfgbuilder is a bare minimum examples of building sf package `sfg` objects from various set-based forms.

This is to augment the official `st_polygon` and alikes so that lists of raw coordinates can be turned into lists of sfg objects with minimal overhead. The aim is to allow various forms of grouping specifications. Currently only allows input of a list of flat vectors, but various XY, XYZ, XYM, XYZM should work for POLYGON. This is specifically to speed up the `spex` package `polygonize` function, but with more support for silicate forms over time.

Dev
---

``` r
tools::package_native_routine_registration_skeleton("../sfgbuilder", "src/init.c",character_only = FALSE)
```

Example
-------

Let's polygonize a raster, i.e. expand its six numbers of extent, dimension into 5 times the product of the dimensions.

``` r
qm <- quadmesh::quadmesh(raster::raster(volcano), z = NULL)
## a dummy structure to copy
template <- structure(list(cbind(1:5, 0)),
                      class = c("XY", "POLYGON", "sfg"))

nquads <- ncol(qm$ib)

idx <- rep(seq(0, nquads), each = 5L) + c(1L, 2L, 3L, 4L, 1L)
quadgroups <- rep(seq_len(nquads), each = 5)
idx <- rbind(qm$ib, qm$ib[1,])
xylist <- split(c(t(qm$vb[1:2, idx])), rep(quadgroups, 2L))
```

Slow code.

``` r
system.time({

## TODO: speed up, this is the slow part of spex::polygonize
 l <- lapply(seq_along(xylist), function(ii) {
   template[[1L]][] <- xylist[[ii]]
   template
 })
})
#>    user  system elapsed 
#>   0.046   0.001   0.046
```

Faster code.

``` r
library(sfgbuilder)
system.time(p <- build_sfg_x(xylist))
#>    user  system elapsed 
#>   0.005   0.000   0.004
```

``` r
identical(l, p)
#> [1] TRUE
```

Does it scale? (Yes, but only up to a point - you don't really want to be creating many polygons like this, it's super-wasteful and unnecessary. This project is an illustration for more general application than this basic task. We *could* make this super fast by not having the mesh and so forth, but it's just not a good idea to expand compact structures like this).

``` r
r <- raster::raster(ncols = 600, nrows = 300)
qm <- quadmesh::quadmesh(r, z = NULL)



nquads <- ncol(qm$ib)
idx <- rep(seq(0, nquads), each = 5L) + c(1L, 2L, 3L, 4L, 1L)
quadgroups <- rep(seq_len(nquads), each = 5)
idx <- rbind(qm$ib, qm$ib[1,])
xylist <- split(c(t(qm$vb[1:2, idx])), rep(quadgroups, 2L))


system.time(p <- build_sfg_x(xylist))
#>    user  system elapsed 
#>   0.621   0.032   0.654

system.time(spex::polygonize(r))
#>    user  system elapsed 
#>   2.966   0.137   3.103

pryr::object_size(r)
#> 10.6 kB
pryr::object_size(quadmesh::quadmesh(r, z = NULL))
#> 11.6 MB
pryr::object_size(p)
#> 82.1 MB
```
