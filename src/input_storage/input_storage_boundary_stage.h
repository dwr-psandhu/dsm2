#ifndef boundary_stage_STORAGE_H__
#define boundary_stage_STORAGE_H__
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

/** Structure representing input of type boundary_stage.
    This class is autogenerated by a script given
    a description of the object
    \ingroup userdata
*/
class boundary_stage
{
public:

  /** Data type boundary_stage, default constructor */  
  typedef const tuple<const std::string>  identifier_type;

  boundary_stage() :
    node(-901),
    used(true),
    layer(0)
  {
    fill_n(name,32,'\0');
    fill_n(fillin,8,'\0');
    fill_n(file,128,'\0');
    fill_n(path,80,'\0');
  };

  /** Construct a boundary_stage with actual data values */
  boundary_stage(const  char a_name[32],const int & a_node,const  char a_fillin[8],const  char a_file[128],const  char a_path[80], bool a_used=true, int a_layer = 0) :
    node(a_node),
    used(a_used),
    layer(a_layer)
  {
    memcpy(name,a_name,32);
    memcpy(fillin,a_fillin,8);
    memcpy(file,a_file,128);
    memcpy(path,a_path,80);  
  }
  
  /**Copy constructor) 
   */
  boundary_stage (const boundary_stage & other) :
    node(other.node),
    used(other.used),
    layer(other.layer)
  {
    memcpy(name,other.name,32);
    memcpy(fillin,other.fillin,8);
    memcpy(file,other.file,128);
    memcpy(path,other.path,80);  
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
  boundary_stage::identifier_type parent_identifier()  const
  {
     return boundary_stage::identifier_type( name );
  }

  /** Return the version/layer number of the parent object */ 
  int parent_version()  const
  {
    vector<boundary_stage>& pbuf = HDFTableManager<boundary_stage>::instance().buffer();
    boundary_stage parent;
    parent.set_identifier(parent_identifier());
    vector<boundary_stage>::iterator loc = lower_bound(pbuf.begin(),
                                                pbuf.end(),
                                                parent,
                                                identifier_compare<boundary_stage>());
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
  bool operator< (const boundary_stage & other) const
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
  bool operator== (const boundary_stage & other) const
  {
     return ((*this < other ) || (other < *this)) ? false : true;
  }
  
  /** Assignment that includes all the data plus the used and layer fields */
  boundary_stage& operator=(const boundary_stage& rhs)
  {
    strcpy(this->name,rhs.name);
    this->node=rhs.node;
    strcpy(this->fillin,rhs.fillin);
    strcpy(this->file,rhs.file);
    strcpy(this->path,rhs.path);
    used = rhs.used;
    layer = rhs.layer;
    return *this;
  }

  /** Return the class name of this object (boundary_stage) */
  string objectName() const
  { 
    return "boundary_stage"; 
  }

  
  char name[32];
  int node;
  char fillin[8];
  char file[128];
  char path[80];
  /** indicator that the entry is used (true if not marked deleted by user)*/
  bool used;  
  /** layer (version number) of this entry */
  int layer;
};

typedef HDFTableManager<boundary_stage> boundary_stage_table;

hid_t string_type(size_t n);

TableDescription boundary_stage_table_description();

istream& operator>> (istream& stream, boundary_stage & obj);
ostream& operator<<(ostream & stream, const boundary_stage & obj);



////////// FORTRAN-LINKABLE API //////////
#define FCALL extern "C"


/**
  Clear the buffer, compatible with fortran
*/  
FCALL void boundary_stage_clear_buffer_f();

/** query number of records being stored in buffer */
FCALL int boundary_stage_buffer_size_f();


/** append to buffer, compatible with fortran, returns new size*/
FCALL void boundary_stage_append_to_buffer_f(const  char a_name[32],const int * a_node,const  char a_fillin[8],const  char a_file[128],const  char a_path[80], int * ierror, 
              const int name_len,const int fillin_len,const int file_len,const int path_len);
  
/** both makes the table and writes the contents of the buffer to it */
FCALL void boundary_stage_write_buffer_to_hdf5_f(const hid_t* file_id, int* ierror);

/** reads the table in from a file into the buffer*/
FCALL void boundary_stage_read_buffer_from_hdf5_f(const hid_t* file_id, int* ierror);

/** query size information about the table in hdf5
*/
FCALL void boundary_stage_number_rows_hdf5_f(const hid_t* file_id, hsize_t* nrecords, int* ierror);


/** get one row worth of information from the buffer */
FCALL void boundary_stage_query_from_buffer_f(size_t* row, 
                         char a_name[32],int * a_node, char a_fillin[8], char a_file[128], char a_path[80], int * ierror, 
              int name_len,int fillin_len,int file_len,int path_len);
/**
  prioritize buffer by layers, delete unused items and sort
  */
FCALL void boundary_stage_prioritize_buffer_f(int* ierror);
/**
   write buffer to the given text file. File will be appended if exists and append flag is set to true.
   otherwise the file will be created or overwritten.
 */
FCALL void boundary_stage_write_buffer_to_text_f(const char* file, const bool* append, int* ierror, int filelen);


#endif

