#ifndef group_member_STORAGE_H__
#define group_member_STORAGE_H__
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
#include "input_storage_group.h"

using namespace std;
using namespace boost;

/** Structure representing input of type group_member.
    This class is autogenerated by a script given
    a description of the object
    \ingroup userdata
*/
class group_member
{
public:

  /** Data type group_member, default constructor */  
  typedef const tuple<const std::string,const std::string>  identifier_type;

  group_member() :
    
    used(true),
    layer(0)
  {
    fill_n(group_name,32,'\0');
    fill_n(member_type,16,'\0');
    fill_n(pattern,32,'\0');
  };

  /** Construct a group_member with actual data values */
  group_member(const  char a_group_name[32],const  char a_member_type[16],const  char a_pattern[32], bool a_used=true, int a_layer = 0) :
    
    used(a_used),
    layer(a_layer)
  {
    memcpy(group_name,a_group_name,32);
    memcpy(member_type,a_member_type,16);
    memcpy(pattern,a_pattern,32);  
  }
  
  /**Copy constructor) 
   */
  group_member (const group_member & other) :
    
    used(other.used),
    layer(other.layer)
  {
    memcpy(group_name,other.group_name,32);
    memcpy(member_type,other.member_type,16);
    memcpy(pattern,other.pattern,32);  
  }
  
  /** Identifier that distinguishes whether two entries are distinct */
  identifier_type identifier()  const
  {  
     return identifier_type( group_name,pattern );
  }
  
  void set_identifier(identifier_type identifier)
  {
     memcpy(group_name,identifier.get<0>().c_str(),32);
      memcpy(pattern,identifier.get<1>().c_str(),32);
  }
  
  /** Parent object class name.
      If this is a child item belonging to a parent, returns
      the name of the parent class. Otherwise returns the name
      of this class.
  */
  group::identifier_type parent_identifier()  const
  {
     return group::identifier_type( group_name );
  }

  /** Return the version/layer number of the parent object */ 
  int parent_version()  const
  {
    vector<group>& pbuf = HDFTableManager<group>::instance().buffer();
    group parent;
    parent.set_identifier(parent_identifier());
    vector<group>::iterator loc = lower_bound(pbuf.begin(),
                                                pbuf.end(),
                                                parent,
                                                identifier_compare<group>());
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
  bool operator< (const group_member & other) const
  {
      return (this->identifier() < other.identifier());
  }

  /** Less-than operator based on the identifier plus (for parent objects) layer number*/  
  bool operator== (const group_member & other) const
  {
     return ((*this < other ) || (other < *this)) ? false : true;
  }
  
  /** Assignment that includes all the data plus the used and layer fields */
  group_member& operator=(const group_member& rhs)
  {
    strcpy(this->group_name,rhs.group_name);
    strcpy(this->member_type,rhs.member_type);
    strcpy(this->pattern,rhs.pattern);
    used = rhs.used;
    layer = rhs.layer;
    return *this;
  }

  /** Return the class name of this object (group_member) */
  string objectName() const
  { 
    return "group_member"; 
  }

  
  char group_name[32];
  char member_type[16];
  char pattern[32];
  /** indicator that the entry is used (true if not marked deleted by user)*/
  bool used;  
  /** layer (version number) of this entry */
  int layer;
};

typedef HDFTableManager<group_member> group_member_table;

hid_t string_type(size_t n);

TableDescription group_member_table_description();

istream& operator>> (istream& stream, group_member & obj);
ostream& operator<<(ostream & stream, const group_member & obj);



////////// FORTRAN-LINKABLE API //////////
#define FCALL extern "C"


/**
  Clear the buffer, compatible with fortran
*/  
FCALL void group_member_clear_buffer_f();

/** query number of records being stored in buffer */
FCALL int group_member_buffer_size_f();


/** append to buffer, compatible with fortran, returns new size*/
FCALL void group_member_append_to_buffer_f(const  char a_group_name[32],const  char a_member_type[16],const  char a_pattern[32], int * ierror, 
              const int group_name_len,const int member_type_len,const int pattern_len);
  
/** both makes the table and writes the contents of the buffer to it */
FCALL void group_member_write_buffer_to_hdf5_f(const hid_t* file_id, int* ierror);

/** reads the table in from a file into the buffer*/
FCALL void group_member_read_buffer_from_hdf5_f(const hid_t* file_id, int* ierror);

/** query size information about the table in hdf5
*/
FCALL void group_member_number_rows_hdf5_f(const hid_t* file_id, hsize_t* nrecords, int* ierror);


/** get one row worth of information from the buffer */
FCALL void group_member_query_from_buffer_f(size_t* row, 
                         char a_group_name[32], char a_member_type[16], char a_pattern[32], int * ierror, 
              int group_name_len,int member_type_len,int pattern_len);
/**
  prioritize buffer by layers, delete unused items and sort
  */
FCALL void group_member_prioritize_buffer_f(int* ierror);
/**
   write buffer to the given text file. File will be appended if exists and append flag is set to true.
   otherwise the file will be created or overwritten.
 */
FCALL void group_member_write_buffer_to_text_f(const char* file, const bool* append, int* ierror, int filelen);


#endif

