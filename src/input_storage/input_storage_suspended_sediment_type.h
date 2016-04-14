#ifndef suspended_sediment_type_STORAGE_H__
#define suspended_sediment_type_STORAGE_H__
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

/** Structure representing input of type suspended_sediment_type.
    This class is autogenerated by a script given
    a description of the object
    \ingroup userdata
*/
class suspended_sediment_type
{
public:

  /** Data type suspended_sediment_type, default constructor */  
  typedef const tuple<const std::string>  identifier_type;

  suspended_sediment_type() :
    
    used(true),
    layer(0)
  {
    fill_n(composition,16,'\0');
    fill_n(method,16,'\0');
  };

  /** Construct a suspended_sediment_type with actual data values */
  suspended_sediment_type(const  char a_composition[16],const  char a_method[16], bool a_used=true, int a_layer = 0) :
    
    used(a_used),
    layer(a_layer)
  {
    memcpy(composition,a_composition,16);
    memcpy(method,a_method,16);  
  }
  
  /**Copy constructor) 
   */
  suspended_sediment_type (const suspended_sediment_type & other) :
    
    used(other.used),
    layer(other.layer)
  {
    memcpy(composition,other.composition,16);
    memcpy(method,other.method,16);  
  }
  
  /** Identifier that distinguishes whether two entries are distinct */
  identifier_type identifier()  const
  {  
     return identifier_type( composition );
  }
  
  void set_identifier(identifier_type identifier)
  {
     memcpy(composition,identifier.get<0>().c_str(),16);
  }
  
  /** Parent object class name.
      If this is a child item belonging to a parent, returns
      the name of the parent class. Otherwise returns the name
      of this class.
  */
  suspended_sediment_type::identifier_type parent_identifier()  const
  {
     return suspended_sediment_type::identifier_type( composition );
  }

  /** Return the version/layer number of the parent object */ 
  int parent_version()  const
  {
    vector<suspended_sediment_type>& pbuf = HDFTableManager<suspended_sediment_type>::instance().buffer();
    suspended_sediment_type parent;
    parent.set_identifier(parent_identifier());
    vector<suspended_sediment_type>::iterator loc = lower_bound(pbuf.begin(),
                                                pbuf.end(),
                                                parent,
                                                identifier_compare<suspended_sediment_type>());
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
  bool operator< (const suspended_sediment_type & other) const
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
  bool operator== (const suspended_sediment_type & other) const
  {
     return ((*this < other ) || (other < *this)) ? false : true;
  }
  
  /** Assignment that includes all the data plus the used and layer fields */
  suspended_sediment_type& operator=(const suspended_sediment_type& rhs)
  {
    strcpy(this->composition,rhs.composition);
    strcpy(this->method,rhs.method);
    used = rhs.used;
    layer = rhs.layer;
    return *this;
  }

  /** Return the class name of this object (suspended_sediment_type) */
  string objectName() const
  { 
    return "suspended_sediment_type"; 
  }

  
  char composition[16];
  char method[16];
  /** indicator that the entry is used (true if not marked deleted by user)*/
  bool used;  
  /** layer (version number) of this entry */
  int layer;
};

typedef HDFTableManager<suspended_sediment_type> suspended_sediment_type_table;

hid_t string_type(size_t n);

TableDescription suspended_sediment_type_table_description();

istream& operator>> (istream& stream, suspended_sediment_type & obj);
ostream& operator<<(ostream & stream, const suspended_sediment_type & obj);



////////// FORTRAN-LINKABLE API //////////
#define FCALL extern "C"


/**
  Clear the buffer, compatible with fortran
*/  
FCALL void suspended_sediment_type_clear_buffer_f();

/** query number of records being stored in buffer */
FCALL int suspended_sediment_type_buffer_size_f();


/** append to buffer, compatible with fortran, returns new size*/
FCALL void suspended_sediment_type_append_to_buffer_f(const  char a_composition[16],const  char a_method[16], int * ierror, 
              const int composition_len,const int method_len);
  
/** both makes the table and writes the contents of the buffer to it */
FCALL void suspended_sediment_type_write_buffer_to_hdf5_f(const hid_t* file_id, int* ierror);

/** reads the table in from a file into the buffer*/
FCALL void suspended_sediment_type_read_buffer_from_hdf5_f(const hid_t* file_id, int* ierror);

/** query size information about the table in hdf5
*/
FCALL void suspended_sediment_type_number_rows_hdf5_f(const hid_t* file_id, hsize_t* nrecords, int* ierror);


/** get one row worth of information from the buffer */
FCALL void suspended_sediment_type_query_from_buffer_f(size_t* row, 
                         char a_composition[16], char a_method[16], int * ierror, 
              int composition_len,int method_len);
/**
  prioritize buffer by layers, delete unused items and sort
  */
FCALL void suspended_sediment_type_prioritize_buffer_f(int* ierror);
/**
   write buffer to the given text file. File will be appended if exists and append flag is set to true.
   otherwise the file will be created or overwritten.
 */
FCALL void suspended_sediment_type_write_buffer_to_text_f(const char* file, const bool* append, int* ierror, int filelen);


#endif

