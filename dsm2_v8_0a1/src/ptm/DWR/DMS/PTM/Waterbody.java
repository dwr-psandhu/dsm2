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

//$Id: Waterbody.java,v 1.3.6.2 2006/01/27 19:52:24 eli2 Exp $
package DWR.DMS.PTM;
import edu.cornell.RngPack.*;
/**
 * A Waterbody is an abstract entity which is connected to other
 * waterbodies via nodes. Each Waterbody is identified by its unique
 * id #. Each Waterbody has a type that is specified by the subtype
 * that creates it.
 *
 * @author Nicky Sandhu
 * @version $Id: Waterbody.java,v 1.3.6.2 2006/01/27 19:52:24 eli2 Exp $
 */
public abstract class Waterbody{

  /**
   *  reservoir type id
   */
  public static final int RESERVOIR = 101;
  /**
   *
   */
  public static final int CHANNEL = 100;
  /**
   *
   */
  public static final int SINK = 104;
  /**
   *
   */
  public static final int BOUNDARY_WATERBODY = 105;
  /**
   *
   */
  public static final int CONVEYOR = 106;
  /**
   *
   */
  public static final int BOUNDARY = BOUNDARY_WATERBODY;
  /**
   *
   */
  public static final int OUTFLOW = -1;
  /**
   *
   */
  public static final int INFLOW = 1;

  public static final int NULL = -10001;
  /**
   *
   */
  public int INITIAL_SEED = 10000;
  /**
   * Construct an empty channel with no nodes
   */
  public Waterbody(){
    this(CHANNEL, 0, null);
  }
  /**
   * Constructs a Waterbody with the given type, with a given number
   * of nodes
   */
  public Waterbody(int wtype, int nId, int[] nodeIds) {
    type = wtype;
    EnvIndex = nId;
    numberId = nId;
    // set # of nodes and odeArray
	if (nodeIds != null){
      nNodes = nodeIds.length;
      nodeIdArray = nodeIds;
      nodeArray = new Node[nNodes];
      depthAt = new float[nNodes];
      flowAt = new float[nNodes];
      velocityAt = new float[nNodes];
      qualityAt = new float[nNodes][getNumConstituents()];
	}
    if(randomNumberGenerator == null)
      randomNumberGenerator = new Ranecu(INITIAL_SEED);
  }
  /**
   *  Gets the flow into a particular Node
   *  Node is identified by its local index
   *  sign convention is that all inflows into Node are positive
   *  all outflows from Node are negative
   */
  public final float getFlowInto(int nodeId){
    float flow=0.0f;
    if (flowType(nodeId) == OUTFLOW) 
      return (flowAt[nodeId]);
    else
      return (-flowAt[nodeId]);
  }
  /**
   * gets direction of flow : OUTFLOW or INFLOW
   */
  public abstract int flowType( int nodeId );
  /**
   *  Gets the type from particle's point of view
   */
  public int getPTMType(){
    return getType();
  }
  /**
   *  Returns actual type of Waterbody
   */
  public int getType(){
    return type;
  }
  /**
   * The type of Waterbody from a hydrodynamic point of view
   */
  public abstract int getHydroType();
  /**
   * gets this Waterbody's unique id
   */
  public final int getEnvIndex(){
    return(EnvIndex);
  }
  /**
   *  Sets pointer information in Node pointer array
   */
  final void setNodeArray(Node[] nodePtrArray){
    for(int i=0; i<nNodes; i++)
      nodeArray[i] = nodePtrArray[i];
  }
  /**
   * gets the local index of a Node (ie. within the
   * indexing system of this Waterbody) from the nodes
   * globalindex
   */
  public final int getNodeLocalIndex(int nodeIdGlobal){
    int nodeIdLocal = -1;
    boolean notFound=true;
    int id=0;
    while (id < nNodes && notFound) {
      if (nodeIdArray[id] == nodeIdGlobal) {
	nodeIdLocal = id;
	notFound = false;
      }
      id++;
    }
    //  if (notFound) 
    // throw new nodeNotFoundException(" Exception in " + this.toString());
    return nodeIdLocal;
  }
  /**
   *  Gets the EnvIndex of the Node indexed by local Node index
   */
  public final int getNodeId(int nodeId){
    return(nodeIdArray[nodeId]);
  }
  /**
   *  the the Node's EnvIndex
   */
  public final int getNodeEnvIndex(int localIndex){
    return(nodeIdArray[localIndex]);
  }
  /**
   *  Generates a sequence of random numbers on subsquent calls
   *  which are gaussian distributed.
   */
  public final float getGRandomNumber(){
    return((float)randomNumberGenerator.gaussian());
  }
  /**
   *  Generate next in series of uniformly distributed random numbers
   */
  public final float getRandomNumber(){
    return( (float) randomNumberGenerator.uniform(0,1));
  }
  /**
   *  the number of nodes
   */
  public final int getNumberOfNodes(){
    return( nNodes );
  }
  /**
   * gets a Node given its local index within this Waterbody.
   * To get a nodes local index use getNodeLocalIndex(int i)
   * @return the Node object
   */
  public final Node getNode(int localIndex){
    return(nodeArray[localIndex]);
  }
  /**
   *  Set flow information to given flow array.
   */
  public final void setFlow(float[] flowArray){
    for( int nodeId =0; nodeId<nNodes; nodeId++)
      flowAt[nodeId] = flowArray[nodeId];
  }
  /**
   * sets the accounting name
   
  public void setAccountingType(int type){
    _aType = type;
  }
  /**
   * Returns the accounting name
   
  public int getAccountingType(){
    return _aType;
  }*/
  /**
   * sets the object number
   */
  public void setObjectType(int type){
    _oType = type;
  }
  /**
    * Returns the object number
    */
  public int getObjectType(){
    return _oType;
  }
  /**
   * sets the group number
   */
  public void setGroup(int group){
    _group = group;
    //    System.out.println(numberId+", group "+group);
  }
  /**
    * Returns the group number
    */
  public int getGroup(){
    return _group;
  }
  /**
   *  returns upstream water quality for constituent
   */
  public float getQuality(int nodeNum, int constituent){
    return qualityAt[nodeNum][constituent];
  }

  /**
   *  returns number of available quality constituents
   */
  public int getNumConstituents(){
    return PTMFixedData.getQualConstituentNames().length;
  }

  /**
   * String representation
   */
  public String toString(){
    String rep = " ";
    if(this != null){
      String typeRep = null;
      if(this.type == CHANNEL) typeRep = "CHANNEL";
      if(this.type == RESERVOIR) typeRep = "RESERVOIR";
      if(this.type == BOUNDARY_WATERBODY) typeRep = "BOUNDARY_WATERBODY";
      if(this.type == CONVEYOR) typeRep = "CONVEYOR";
      rep = " Waterbody # " + this.EnvIndex + "\n" 
	+ " Number of Nodes = " + this.nNodes + "\n"
	+ " Waterbody Type is " + typeRep + "\n";
      for(int i=0; i<nNodes; i++){
	if(nodeArray[i] != null) 
	  rep += "Node["+i+"] = " +nodeArray[i].getEnvIndex();
	else 
	  rep += "Node["+i+"] = null";
      }
    }
    return rep;
  }

  /**
   *  index in PTMEnv Waterbody array
   */
  private int EnvIndex;
  /**
   *  Id of array in the DSM2 hydro grid
   */
  private int numberId;
  /**
   *  type of Waterbody channel/reservoir/boundary/conveyor
   */
  private int type;
  /**
   *  number of nodes connecting to this Waterbody
   */
  private int nNodes;
  /**
   *  Array of Node indices to which Waterbody is connected
   */
  private int[] nodeIdArray;
  /**
   *  pointers to Node objects to which Waterbody is connected
   */
  private Node[] nodeArray;
  
  /**
   *  Flow, depth, velocity, width and area information read from tide file
   */
  protected float[] flowAt, depthAt, velocityAt, widthAt;
  /**
   *  Water quality information read from Qual binary file
   */
  protected float[][] qualityAt;
  /**
   *  gaussian random number generator
   */
  private RandomElement randomNumberGenerator;

  /**
   * The object name
   */
  private int _oType;
  /**
   * The group number
   */
  private int _group;
}
