#ifndef particle_group_output_STORAGE_H__
#define particle_group_output_STORAGE_H__
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

/** Structure representing input of type particle_group_output.
    This class is autogenerated by a script given
    a description of the object
    \ingroup userdata
*/
class particle_group_output
{
public:

  /** Data type particle_group_output, default constructor */  
  typedef const tuple<const std::string>  identifier_type;

  particle_group_output() :
    
    used(true),
    layer(0)
  {
    fill_n(name,32,'\0');
    fill_n(group_name,40,'\0');
    fill_n(interval,16,'\0');
    fill_n(file,128,'\0');
  };

  /** Construct a particle_group_output with actual data values */
  particle_group_output(const  char a_name[32],const  char a_group_name[40],const  char a_interval[16],const  char a_file[128], bool a_used=true, int a_layer = 0) :
    
    used(a_used),
    layer(a_layer)
  {
    memcpy(name,a_name,32);
    memcpy(group_name,a_group_name,40);
    memcpy(interval,a_interval,16);
    memcpy(file,a_file,128);  
  }
  
  /**Copy constructor) 
   */
  particle_group_output (const particle_group_output & other) :
    
    used(other.used),
    layer(other.layer)
  {
    memcpy(name,other.name,32);
    memcpy(group_name,other.group_name,40);
    memcpy(interval,other.interval,16);
    memcpy(file,other.file,128);  
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
  particle_group_output::identifier_type parent_identifier()  const
  {
     return particle_group_output::identifier_type( name );
  }

  /** Return the version/layer number of the parent object */ 
  int parent_version()  const
  {
    vector<particle_group_output>& pbuf = HDFTableManager<particle_group_output>::instance().buffer();
    particle_group_output parent;
    parent.set_identifier(parent_identifier());
    vector<particle_group_output>::iterator loc = lower_bound(pbuf.begin(),
                                                pbuf.end(),
                                                parent,
                                                identifier_compare<particle_group_output>());
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
  bool operator< (const particle_group_output & other) const
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
  bool operator== (const particle_group_output & other) const
  {
     return ((*this < other ) || (other < *this)) ? false : true;
  }
  
  /** Assignment that includes all the data plus the used and layer fields */
  particle_group_output& operator=(const particle_group_output& rhs)
  {
    strcpy(this->name,rhs.name);
    strcpy(this->group_name,rhs.group_name);
    strcpy(this->interval,rhs.interval);
    strcpy(this->file,rhs.file);
    used = rhs.used;
    layer = rhs.layer;
    return *this;
  }

  /** Return the class name of this object (particle_group_output) */
  string objectName() const
  { 
    return "particle_group_output"; 
  }

  
  char name[32];
  char group_name[40];
  char interval[16];
  char file[128];
  /** indicator that the entry is used (true if not marked deleted by user)*/
  bool used;  
  /** layer (version number) of this entry */
  int layer;
};

typedef HDFTableManager<particle_group_output> particle_group_output_table;

hid_t string_type(size_t n);

TableDescription particle_group_output_table_description();

istream& operator>> (istream& stream, particle_group_output & obj);
ostream& operator<<(ostream & stream, const particle_group_output & obj);



////////// FORTRAN-LINKABLE API //////////
#define FCALL extern "C"


/**
  Clear the buffer, compatible with fortran
*/  
FCALL void particle_group_output_clear_buffer_f();

/** query number of records being stored in buffer */
FCALL int particle_group_output_buffer_size_f();


/** append to buffer, compatible with fortran, returns new size*/
FCALL void particle_group_output_append_to_buffer_f(const  char a_name[32],const  char a_group_name[40],const  char a_interval[16],const  char a_file[128], int * ierror, 
              const int name_len,const int group_name_len,const int interval_len,const int file_len);
  
/** both makes the table and writes the contents of the buffer to it */
FCALL void particle_group_output_write_buffer_to_hdf5_f(const hid_t* file_id, int* ierror);

/** reads the table in from a file into the buffer*/
FCALL void particle_group_output_read_buffer_from_hdf5_f(const hid_t* file_id, int* ierror);

/** query size information about the table in hdf5
*/
FCALL void particle_group_output_number_rows_hdf5_f(const hid_t* file_id, hsize_t* nrecords, int* ierror);


/** get one row worth of information from the buffer */
FCALL void particle_group_output_query_from_buffer_f(size_t* row, 
                         char a_name[32], char a_group_name[40], char a_interval[16], char a_file[128], int * ierror, 
              int name_len,int group_name_len,int interval_len,int file_len);
/**
  prioritize buffer by layers, delete unused items and sort
  */
FCALL void particle_group_output_prioritize_buffer_f(int* ierror);
/**
   write buffer to the given text file. File will be appended if exists and append flag is set to true.
   otherwise the file will be created or overwritten.
 */
FCALL void particle_group_output_write_buffer_to_text_f(const char* file, const bool* append, int* ierror, int filelen);


#endif

