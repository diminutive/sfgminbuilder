context("test-sfg.R")

## build sf is too slow

qm <- quadmesh::quadmesh(raster::raster(matrix(1:12, 3)), z = NULL)
## a dummy structure to copy
template <- structure(list(cbind(1:5, 0)),
                      class = c("XY", "POLYGON", "sfg"))

nquads <- ncol(qm$ib)

idx <- rep(seq(0, nquads), each = 5L) + c(1L, 2L, 3L, 4L, 1L)
quadgroups <- rep(seq_len(nquads), each = 5)
idx <- rbind(qm$ib, qm$ib[1,])
xylist <- split(c(t(qm$vb[1:2, idx])), rep(quadgroups, 2L))
## TODO: speed up, this is the slow part
 l <- lapply(seq_along(xylist), function(ii) {
   template[[1L]][] <- xylist[[ii]]
   template
 })

p <- build_polygons(xylist)

test_that("multiplication works", {
  expect_identical(l, p)
})
