#include <Rcpp.h>
using namespace Rcpp;


//' Build sf
//'
//' @param data_xy list of xy data with no structure
//' @export
// [[Rcpp::export]]
List build_polygons(List data_xy) {

  int nsfg = data_xy.length();
  Rcpp::List rectlist(nsfg);
  Rcpp::List sfglist(1);
  sfglist.attr("class") = CharacterVector::create("XY", "POLYGON", "sfg");



  for (int idata = 0; idata < nsfg; idata++) {
    const Rcpp::NumericVector xydata = data_xy[idata];
    Rcpp::NumericVector xydata2 = Rcpp::clone(xydata);
    Rcpp::List sfglist2 = Rcpp::clone(sfglist);
   //xydata = data_xy[idata];
    xydata2.attr("dim") = Dimension(5, 2);
    sfglist2[0] = xydata2;
    rectlist[idata] = sfglist2;
  }
  return rectlist;
}


