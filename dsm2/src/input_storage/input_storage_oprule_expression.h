#ifndef oprule_expression_STORAGE_H__
#define oprule_expression_STORAGE_H__
/**
WARNING: THIS FILE WAS AUTOMATICALLY GENERATED USING A SCRIPT AND A TEMPLATE  
DO NOT CHANGE THE CODE HERE. 
IF THE CODE IS INCORRECT, FIX THE TEMPLATE OR SCRIPT
IF YOU WANT TO ADD NEW ITEMS, ADD THEM TO THE SCRIPT INPUT FILE AND RUN IT AFRESH
*/ 
#define _CRT_SECURE_NO_DEPRECATE  // viz studio deprecation warnings
#include "hdf5.h"
#include "hdf5_hl.h"
#include "hdf_storage.h"
#include "HDFTableManager.h"
#include "TableDescription.h"
#include "TableItemFunctors.h"
#include "boost/tuple/tuple_comparison.hpp"
#include "boost/tuple/tuple_io.hpp"
#include<iostream>
#include<vector>
#include<algorithm>
#include<string.h>
#include<iostream>


using namespace std;
using namespace boost;

/** Structure representing input of type oprule_expression.
    This class is autogenerated by a script given
    a description of the object
    \ingroup userdata
*/
class oprule_expression
{
public:

  /** Data type oprule_expression, default constructor */  
  typedef const boost::tuple<const std::string>  identifier_type;

  oprule_expression() :
    
    used(true),
    layer(0)
  {
    fill_n(name,32,'\0');
    fill_n(definition,512,'\0');
  };

  /** Construct a oprule_expression with actual data values */
  oprule_expression(const  char a_name[32],const  char a_definition[512], bool a_used=true, int a_layer = 0) :
    
    used(a_used),
    layer(a_layer)
  {
    memcpy(name,a_name,32);
    memcpy(definition,a_definition,512);  
  }
  
  /**Copy constructor) 
   */
  oprule_expression (const oprule_expression & other) :
    
    used(other.used),
    layer(other.layer)
  {
    memcpy(name,other.name,32);
    memcpy(definition,other.definition,512);  
  }
  
  /** Identifier that distinguishes whether two entries are distinct */
  identifier_type identifier()  const
  {  
     return identifier_type( name );
  }
  
  void set_identifier(identifier_type identifier)
  {
     memcpy(name,identifier.get<0>().c_str(),32);
  }
  
  /** Parent object class name.
      If this is a child item belonging to a parent, returns
      the name of the parent class. Otherwise returns the name
      of this class.
  */
  oprule_expression::identifier_type parent_identifier()  const
  {
     return oprule_expression::identifier_type( name );
  }

  /** Return the version/layer number of the parent object */ 
  int parent_version()  const
  {
    vector<oprule_expression>& pbuf = HDFTableManager<oprule_expression>::instance().buffer();
    oprule_expression parent;
    parent.set_identifier(parent_identifier());
    vector<oprule_expression>::iterator loc = lower_bound(pbuf.begin(),
                                                pbuf.end(),
                                                parent,
                                                identifier_compare<oprule_expression>());
    bool found = (loc!=pbuf.end()) && loc->identifier() == parent.identifier();    
    if (found && loc->used){ return loc->layer; }
    else{ return -1; }
  }

  /** Return true if this layer of this object matches the layer of the parent object that will be use in the model.*/
  bool parent_valid()  const
  {
    return this->layer == parent_version();
  }

  /** Less-than operator based on the identifier plus (for parent objects) layer number*/  
  bool operator< (const oprule_expression & other) const
  {
     
     if(this->identifier() != other.identifier())
	 {
		 return this->identifier() < other.identifier();
	 }
	 // todo: make this a policy
	 bool layerOutranks = (this->layer == 0 && other.layer != 0) ||
		                  (this->layer > other.layer && other.layer != 0);
     return layerOutranks;

  }

  /** Less-than operator based on the identifier plus (for parent objects) layer number*/  
  bool operator== (const oprule_expression & other) const
  {
     return ((*this < other ) || (other < *this)) ? false : true;
  }
  
  /** Assignment that includes all the data plus the used and layer fields */
  oprule_expression& operator=(const oprule_expression& rhs)
  {
    strcpy(this->name,rhs.name);
    strcpy(this->definition,rhs.definition);
    used = rhs.used;
    layer = rhs.layer;
    return *this;
  }

  /** Return the class name of this object (oprule_expression) */
  string objectName() const
  { 
    return "oprule_expression"; 
  }

  
  char name[32];
  char definition[512];
  /** indicator that the entry is used (true if not marked deleted by user)*/
  bool used;  
  /** layer (version number) of this entry */
  int layer;
};

typedef HDFTableManager<oprule_expression> oprule_expression_table;

hid_t string_type(size_t n);

TableDescription oprule_expression_table_description();

istream& operator>> (istream& stream, oprule_expression & obj);
ostream& operator<<(ostream & stream, const oprule_expression & obj);



////////// FORTRAN-LINKABLE API //////////
#define FCALL extern "C"


/**
  Clear the buffer, compatible with fortran
*/  
FCALL void oprule_expression_clear_buffer_f();

/** query number of records being stored in buffer */
FCALL int oprule_expression_buffer_size_f();


/** append to buffer, compatible with fortran, returns new size*/
FCALL void oprule_expression_append_to_buffer_f(const  char a_name[32],const  char a_definition[512], int * ierror, 
              const int name_len,const int definition_len);
  
/** both makes the table and writes the contents of the buffer to it */
FCALL void oprule_expression_write_buffer_to_hdf5_f(const hid_t* file_id, int* ierror);

/** reads the table in from a file into the buffer*/
FCALL void oprule_expression_read_buffer_from_hdf5_f(const hid_t* file_id, int* ierror);

/** query size information about the table in hdf5
*/
FCALL void oprule_expression_number_rows_hdf5_f(const hid_t* file_id, hsize_t* nrecords, int* ierror);


/** get one row worth of information from the buffer */
FCALL void oprule_expression_query_from_buffer_f(size_t* row, 
                         char a_name[32], char a_definition[512], int * ierror, 
              int name_len,int definition_len);
/**
  prioritize buffer by layers, delete unused items and sort
  */
FCALL void oprule_expression_prioritize_buffer_f(int* ierror);
/**
   write buffer to the given text file. File will be appended if exists and append flag is set to true.
   otherwise the file will be created or overwritten.
 */
FCALL void oprule_expression_write_buffer_to_text_f(const char* file, const bool* append, int* ierror, int filelen);


#endif
