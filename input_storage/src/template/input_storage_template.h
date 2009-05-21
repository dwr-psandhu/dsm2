#ifndef @TABLEOBJ_STORAGE_H__
#define @TABLEOBJ_STORAGE_H__
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
@HEADERPARENT

using namespace std;
using namespace boost;

/** Structure representing input of type @TABLEOBJ.
    This class is autogenerated by a script given
    a description of the object
    \ingroup userdata
*/
class @TABLEOBJ
{
public:

  /** Data type @TABLEOBJ, default constructor */  
  typedef const tuple<@IDENTIFIERTYPES>  identifier_type;

  @TABLEOBJ() :
    @DEFAULT_MEMBER_INIT
    used(true),
    layer(0)
  {
    @DEFAULTCONSTRUCT
  };

  /** Construct a @TABLEOBJ with actual data values */
  @TABLEOBJ(@C_INPUT_SIGNATURE, bool a_used=true, int a_layer = 0) :
    @INIT
    used(a_used),
    layer(a_layer)
  {
    @CONSTRUCT  
  }
  
  /**Copy constructor) 
   */
  @TABLEOBJ (const @TABLEOBJ & other) :
    @COPYINIT
    used(other.used),
    layer(other.layer)
  {
    @COPYCONSTRUCT  
  }
  
  /** Identifier that distinguishes whether two entries are distinct */
  identifier_type identifier()  const
  {  
     return identifier_type( @IDENTIFIERS );
  }
  
  void set_identifier(identifier_type identifier)
  {
     @IDENTIFIERASSIGN
  }
  
  /** Parent object class name.
      If this is a child item belonging to a parent, returns
      the name of the parent class. Otherwise returns the name
      of this class.
  */
  @PARENT::identifier_type parent_identifier()  const
  {
     return @PARENT::identifier_type( @ZPARENTIDENTIFIERS );
  }

  /** Return the version/layer number of the parent object */ 
  int parent_version()  const
  {
    vector<@PARENT>& pbuf = HDFTableManager<@PARENT>::instance().buffer();
    @PARENT parent;
    parent.set_identifier(parent_identifier());
    vector<@PARENT>::iterator loc = lower_bound(pbuf.begin(),
                                                pbuf.end(),
                                                parent,
                                                identifier_compare<@PARENT>());
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
  bool operator< (const @TABLEOBJ & other) const
  {
     return @COMPARETABLEITEM;
  }

  /** Less-than operator based on the identifier plus (for parent objects) layer number*/  
  bool operator== (const @TABLEOBJ & other) const
  {
     return ((*this < other ) || (other < *this)) ? false : true;
  }
  
  /** Assignment that includes all the data plus the used and layer fields */
  @TABLEOBJ& operator=(const @TABLEOBJ& rhs)
  {
    @EQUALOP
    used = rhs.used;
    layer = rhs.layer;
    return *this;
  }

  /** Return the class name of this object (@TABLEOBJ) */
  string objectName() const
  { 
    return "@TABLEOBJ"; 
  }

  
  @MEMBERS
  /** layer (version number) of this entry */
  int layer;
  /** indicator that the entry is used (true if not marked deleted by user)*/
  bool used;  
};

typedef HDFTableManager<@TABLEOBJ> @TABLEOBJ_table;

hid_t string_type(size_t n);

TableDescription @TABLEOBJ_table_description();

istream& operator>> (istream& stream, @TABLEOBJ & obj);
ostream& operator<<(ostream & stream, const @TABLEOBJ & obj);



////////// FORTRAN-LINKABLE API //////////
#define FCALL extern "C"


/**
  Clear the buffer, compatible with fortran
*/  
FCALL void @TABLEOBJ_clear_buffer_f();

/** query number of records being stored in buffer */
FCALL int @TABLEOBJ_buffer_size_f();


/** append to buffer, compatible with fortran, returns new size*/
FCALL void @TABLEOBJ_append_to_buffer_f(@FORTRAN_C_INPUT_SIGNATURE);
  
/** both makes the table and writes the contents of the buffer to it */
FCALL void @TABLEOBJ_write_buffer_to_hdf5_f(const hid_t* file_id, int* ierror);

/** reads the table in from a file into the buffer*/
FCALL void @TABLEOBJ_read_buffer_from_hdf5_f(const hid_t* file_id, int* ierror);

/** query size information about the table in hdf5
*/
FCALL void @TABLEOBJ_number_rows_hdf5_f(const hid_t* file_id, hsize_t* nrecords, int* ierror);


/** get one row worth of information from the buffer */
FCALL void @TABLEOBJ_query_from_buffer_f(size_t* row, 
                        @FORTRAN_C_OUTPUT_SIGNATURE);
/**
  prioritize buffer by layers, delete unused items and sort
  */
FCALL void @TABLEOBJ_prioritize_buffer_f(int* ierror);
/**
   write buffer to the given text file. File will be appended if exists and append flag is set to true.
   otherwise the file will be created or overwritten.
 */
FCALL void @TABLEOBJ_write_buffer_to_text_f(const char* file, const bool* append, int* ierror, int filelen);


#endif

