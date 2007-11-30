#include "dsm2_expressions.h"
#include "oprule/expression/ExpressionNode.h"
#include<vector>
#include<algorithm>
#define get_expression_data GET_EXPRESSION_DATA

typedef std::vector<oprule::expression::DoubleNodePtr> data_expr_container;
data_expr_container expr_used_as_data;
typedef data_expr_container::iterator data_expr_iter;

extern "C" double __stdcall get_expression_data(int* express){
   return (expr_used_as_data[*express])->eval(); 
}

int register_express_for_data_source(
   oprule::expression::DoubleNode::NodePtr expr){
   data_expr_iter it=std::find(expr_used_as_data.begin(),
                          expr_used_as_data.end(),expr);
   if ( it != expr_used_as_data.end()){
      return it - expr_used_as_data.begin(); //@todo: is this safe?
   }else{
      expr_used_as_data.push_back(expr);
      return expr_used_as_data.size()-1;     //@todo: is this safe?
   }
}