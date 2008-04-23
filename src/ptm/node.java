/*<license>
C!    Copyright (C) 1996, 1997, 1998, 2001, 2007 State of California,
C!    Department of Water Resources.
C!    This file is part of DSM2.

C!    DSM2 is free software: you can redistribute it and/or modify
C!    it under the terms of the GNU General Public !<license as published by
C!    the Free Software Foundation, either version 3 of the !<license, or
C!    (at your option) any later version.

C!    DSM2 is distributed in the hope that it will be useful,
C!    but WITHOUT ANY WARRANTY; without even the implied warranty of
C!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C!    GNU General Public !<license for more details.

C!    You should have received a copy of the GNU General Public !<license
C!    along with DSM2.  If not, see <http://www.gnu.org/!<licenses/>.
</license>*/

package DWR.DMS.PTM;
import java.lang.*;
import java.util.*;
import edu.cornell.RngPack.*;

/**
 * 
 *  node
 * 
 *  Node is defined as the connection between two or more waterbodies.
 *  Node handles connection information as well as constructing outflow
 *  from or to kind of information
 *  <p>
 * 
 *  FUTURE DIRECTIONS
 *  <p>
 */

public class node{
private RandomElement randomNumberGenerator;
private static int INITIAL_SEED = 10000;
  /**
   *  node constructor
   */
public node(int nId, int[] wbIdArray, String bdType){
  EnvIndex = nId;
  //set the number of waterbodies & number upstream / downstream channels
  //? This is number of channels only.. add ag. drains, pumps, reservoirs
  //? later as that would information would have to be extracted from 
  //? reservoirs, pumps, and ag. drains.
  numberOfWaterbodies = wbIdArray.length;
  // create arrays to store index of array of waterbodies in PTMEnv
  //? This will later be converted to pointer information.. ie. an
  //? array of pointers to waterbodies..
  wbIndexArray = new int[numberOfWaterbodies];
  wbArray = new waterbody[numberOfWaterbodies];
  for (int i=0 ; i<numberOfWaterbodies; i++){
    wbIndexArray[i] = wbIdArray[i];
  }
  boundaryType = bdType;
  randomNumberGenerator = new Ranecu(INITIAL_SEED);
} 
  
  /**
   *  simpler node initializer
   */
public node(int nId){
  EnvIndex = nId;
  numberOfWaterbodies=0;
  LABoundaryType = -1;
}
  
  
  /**
   *  Clean up only if initialized
   */
  
  
  /**
   *  Returns the next random number using drand48
   */
public final float getRandomNumber(){
  return (float) randomNumberGenerator.uniform(0,1);
}
  
  
  /**
   *  Returns number of waterbodies
   */
public final int getNumberOfWaterbodies(){
  return (numberOfWaterbodies);
}
  
  
  /**
   *  Returns an integer pointing to the number Id of the waterbody
   */
public final int getWaterbodyId(int id){
  return(wbArray[id].getEnvIndex());
}
  
  
  /**
   *  Returns a pointer to desired waterbody
   */
public final waterbody getWaterbody(int id){
  return(wbArray[id]);
}
  
  
  /**
   *  Checks to see if junction is a dead end.
   */
public final boolean isJunctionDeadEnd(){
  return(false);
}
  
  
  /**
   *  Get total positive outflow from node.. add up all flows leaving the node
   */
public final float getTotalOutflow(boolean addSeep){
  float outflow=0.0f;
  //  System.out.println(this.toString());
  // for each waterbody connected to junction add the outflows
  for (int id=0; id < numberOfWaterbodies; id++) {
	  if(!addSeep){  //@todo: hobbled seep feature
		  //if(getWaterbody(id).getAccountingType() != flowTypes.evap){
             outflow += getOutflow(id);
		  //}
	  }
	  else{
		  outflow += getOutflow(id);
	  }
  }
  return (outflow);
}
  
  
  /**
   *  Gets the positive outflow to a particular waterbody from this node.
   *  It returns a zero for negative outflow or inflow
   */
public final float getOutflow(int id)  {
  // get out flow from junction, returns 0 if negative
  return Math.max(0.0f,getSignedOutflow(id));
}
  
  
public final float getSignedOutflow(int id) {
  int junctionIdInWaterbody= 0;
  //  System.out.println("In signed outflow: index: " + id 
  //		     + " wb[i]= "   + wbArray[id]);
  junctionIdInWaterbody = wbArray[id].getNodeLocalIndex(EnvIndex);
  if (junctionIdInWaterbody == -1)
    System.out.println("Exception thrown in node " + this.toString());
  return wbArray[id].getFlowInto(junctionIdInWaterbody);
}
  
  
  /**
   *  Returns the index to the node array in PTMEnv
   */
public final int getEnvIndex(){
  return(EnvIndex);
}
  
  
  /**
   *  Returns the index of waterbody in PTMEnv array using local index
   */
public final int getWaterbodyEnvIndex(int localIndex){
  return(wbIndexArray[localIndex]);
}
  
  
  /**
   *  Fills the wbArray with pointer information and cleans up the index array
   */
public final void setWbArray(waterbody[] wbPtrArray){
  for(int i=0; i< numberOfWaterbodies; i++){
    wbArray[i] = wbPtrArray[i];
  }
  cleanUp();
}
  
  
  /**
   *  Adds waterbody of given PTMEnv index to node wbIndexArray.
   *  These operations should be done prior to calling setWbArray
   */
public final void addWaterbodyId(int envIndex){
  
  if(numberOfWaterbodies > 0) {
    // store waterbody indices and types in temporary arrays...
    int[] indexArray = new int[numberOfWaterbodies+1];
    for(int i=0; i< numberOfWaterbodies; i++) {
      indexArray[i] = wbIndexArray[i];
    }
    
    // delete the memory for these arrays
    wbIndexArray = null;
    wbArray = null;
    // increment the number of waterbodies
    numberOfWaterbodies++;
    
    // reallocate bigger chunks of memory
    wbIndexArray = new int[numberOfWaterbodies];
    wbArray = new waterbody[numberOfWaterbodies];
    
    // fill them up again..
    for(int i=0; i< numberOfWaterbodies-1; i++){
      wbIndexArray[i] = indexArray[i];
    }
    wbIndexArray[numberOfWaterbodies-1] = envIndex;
    indexArray = null;
  }
  else{
    numberOfWaterbodies=1;
    wbIndexArray = new int[numberOfWaterbodies];
    wbArray = new waterbody[numberOfWaterbodies];
    wbIndexArray[numberOfWaterbodies-1] = envIndex;
  }
}
  /**
   * String representation
   */
public String toString(){
  String rep = null;
  if (this != null) {
    rep =  " Node # " + this.EnvIndex + "\n" 
      + " Number of Waterbodies = " + this.numberOfWaterbodies + "\n";
    for(int i=0 ; i< getNumberOfWaterbodies(); i++)
      rep += " Waterbody # " + i + " EnvIndex is " + wbIndexArray[i];
  }
  return rep; 
}
  
  /**
   *  Index to array in PTMEnv
   */
  private int EnvIndex;
  
  /**
   *  Number of waterbodies
   */
  private int numberOfWaterbodies;
  
  /**
   *  An array of pointers to waterbodies
   */
  private waterbody[] wbArray;
  
  /**
   *  A storage for index of waterbodies in PTMEnv till wbArray
   *  gets filled.
   */
  private int[] wbIndexArray;
  
  /**
   *  Boundary array as defined from fixed input. This is not needed
   *  for boundary waterbody information as only waterbodies can be
   *  boundaries.
   */
  private String boundaryType;
  
  /**
   *  Length of boundary array.
   */
  private int LABoundaryType;
  
  /**
   *  deletes wbIndexArray and anything else to save space.
   */
private final void cleanUp(){
  //  wbIndexArray = null;
}

};



