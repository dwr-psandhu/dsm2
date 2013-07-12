#ifndef output_channel_source_track_STORAGE_H__
#define output_channel_source_track_STORAGE_H__
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

/** Structure representing input of type output_channel_source_track.
    This class is autogenerated by a script given
    a description of the object
    \ingroup userdata
*/
class output_channel_source_track
{
public:

  /** Data type output_channel_source_track, default constructor */  
  typedef const tuple<const std::string,const std::string,const std::string>  identifier_type;

  output_channel_source_track() :
    chan_no(-901),
    used(true),
    layer(0)
  {
    fill_n(name,32,'\0');
    fill_n(distance,8,'\0');
    fill_n(variable,16,'\0');
    fill_n(source_group,32,'\0');
    fill_n(interval,16,'\0');
    fill_n(period_op,16,'\0');
    fill_n(file,128,'\0');
  };

  /** Construct a output_channel_source_track with actual data values */
  output_channel_source_track(const  char a_name[32],const int & a_chan_no,const  char a_distance[8],const  char a_variable[16],const  char a_source_group[32],const  char a_interval[16],const  char a_period_op[16],const  char a_file[128], bool a_used=true, int a_layer = 0) :
    chan_no(a_chan_no),
    used(a_used),
    layer(a_layer)
  {
    memcpy(name,a_name,32);
    memcpy(distance,a_distance,8);
    memcpy(variable,a_variable,16);
    memcpy(source_group,a_source_group,32);
    memcpy(interval,a_interval,16);
    memcpy(period_op,a_period_op,16);
    memcpy(file,a_file,128);  
  }
  
  /**Copy constructor) 
   */
  output_channel_source_track (const output_channel_source_track & other) :
    chan_no(other.chan_no),
    used(other.used),
    layer(other.layer)
  {
    memcpy(name,other.name,32);
    memcpy(distance,other.distance,8);
    memcpy(variable,other.variable,16);
    memcpy(source_group,other.source_group,32);
    memcpy(interval,other.interval,16);
    memcpy(period_op,other.period_op,16);
    memcpy(file,other.file,128);  
  }
  
  /** Identifier that distinguishes whether two entries are distinct */
  identifier_type identifier()  const
  {  
     return identifier_type( name,variable,source_group );
  }
  
  void set_identifier(identifier_type identifier)
  {
     memcpy(name,identifier.get<0>().c_str(),32);
      memcpy(variable,identifier.get<1>().c_str(),16);
      memcpy(source_group,identifier.get<2>().c_str(),32);
  }
  
  /** Parent object class name.
      If this is a child item belonging to a parent, returns
      the name of the parent class. Otherwise returns the name
      of this class.
  */
  output_channel_source_track::identifier_type parent_identifier()  const
  {
     return output_channel_source_track::identifier_type( name,variable,source_group );
  }

  /** Return the version/layer number of the parent object */ 
  int parent_version()  const
  {
    vector<output_channel_source_track>& pbuf = HDFTableManager<output_channel_source_track>::instance().buffer();
    output_channel_source_track parent;
    parent.set_identifier(parent_identifier());
    vector<output_channel_source_track>::iterator loc = lower_bound(pbuf.begin(),
                                                pbuf.end(),
                                                parent,
                                                identifier_compare<output_channel_source_track>());
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
  bool operator< (const output_channel_source_track & other) const
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
  bool operator== (const output_channel_source_track & other) const
  {
     return ((*this < other ) || (other < *this)) ? false : true;
  }
  
  /** Assignment that includes all the data plus the used and layer fields */
  output_channel_source_track& operator=(const output_channel_source_track& rhs)
  {
    strcpy(this->name,rhs.name);
    this->chan_no=rhs.chan_no;
    strcpy(this->distance,rhs.distance);
    strcpy(this->variable,rhs.variable);
    strcpy(this->source_group,rhs.source_group);
    strcpy(this->interval,rhs.interval);
    strcpy(this->period_op,rhs.period_op);
    strcpy(this->file,rhs.file);
    used = rhs.used;
    layer = rhs.layer;
    return *this;
  }

  /** Return the class name of this object (output_channel_source_track) */
  string objectName() const
  { 
    return "output_channel_source_track"; 
  }

  
  char name[32];
  int chan_no;
  char distance[8];
  char variable[16];
  char source_group[32];
  char interval[16];
  char period_op[16];
  char file[128];
  /** indicator that the entry is used (true if not marked deleted by user)*/
  bool used;  
  /** layer (version number) of this entry */
  int layer;
};

typedef HDFTableManager<output_channel_source_track> output_channel_source_track_table;

hid_t string_type(size_t n);

TableDescription output_channel_source_track_table_description();

istream& operator>> (istream& stream, output_channel_source_track & obj);
ostream& operator<<(ostream & stream, const output_channel_source_track & obj);



////////// FORTRAN-LINKABLE API //////////
#define FCALL extern "C"


/**
  Clear the buffer, compatible with fortran
*/  
FCALL void output_channel_source_track_clear_buffer_f();

/** query number of records being stored in buffer */
FCALL int output_channel_source_track_buffer_size_f();


/** append to buffer, compatible with fortran, returns new size*/
FCALL void output_channel_source_track_append_to_buffer_f(const  char a_name[32],const int * a_chan_no,const  char a_distance[8],const  char a_variable[16],const  char a_source_group[32],const  char a_interval[16],const  char a_period_op[16],const  char a_file[128], int * ierror, 
              const int name_len,const int distance_len,const int variable_len,const int source_group_len,const int interval_len,const int period_op_len,const int file_len);
  
/** both makes the table and writes the contents of the buffer to it */
FCALL void output_channel_source_track_write_buffer_to_hdf5_f(const hid_t* file_id, int* ierror);

/** reads the table in from a file into the buffer*/
FCALL void output_channel_source_track_read_buffer_from_hdf5_f(const hid_t* file_id, int* ierror);

/** query size information about the table in hdf5
*/
FCALL void output_channel_source_track_number_rows_hdf5_f(const hid_t* file_id, hsize_t* nrecords, int* ierror);


/** get one row worth of information from the buffer */
FCALL void output_channel_source_track_query_from_buffer_f(size_t* row, 
                         char a_name[32],int * a_chan_no, char a_distance[8], char a_variable[16], char a_source_group[32], char a_interval[16], char a_period_op[16], char a_file[128], int * ierror, 
              int name_len,int distance_len,int variable_len,int source_group_len,int interval_len,int period_op_len,int file_len);
/**
  prioritize buffer by layers, delete unused items and sort
  */
FCALL void output_channel_source_track_prioritize_buffer_f(int* ierror);
/**
   write buffer to the given text file. File will be appended if exists and append flag is set to true.
   otherwise the file will be created or overwritten.
 */
FCALL void output_channel_source_track_write_buffer_to_text_f(const char* file, const bool* append, int* ierror, int filelen);


#endif

