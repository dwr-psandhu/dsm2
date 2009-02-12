#ifndef PARSEVALIDATIONFUNCTORS_H__
#define PARSEVALIDATIONFUNCTORS_H__
#include<string>
#include "boost/algorithm/string/find.hpp"
#include "boost/algorithm/string/classification.hpp"
#include "boost/algorithm/string/predicate.hpp"

/**\defgroup ParseValidationFunctors String validation functors*/

/** Functor that returns true if a string is not empty \ingroup ParseValidationFunctors*/
struct is_not_empty {
  bool operator()(const string & x) 
  {
    return x != "";
  }
};

/** Functor that returns true if a string contains no spaces \ingroup ParseValidationFunctors*/
struct is_no_spaces
{
  bool operator()(const string & x) 
  {
    return x.find_first_of(" ") == string::npos;
  }
};

/** Functor that checks if the entire input string is lower case \ingroup ParseValidationFunctors*/
struct is_all_lower
{
  bool operator()(const string & x) 
  {
    return boost::algorithm::all( x, is_lower() );
  }
};




#endif
