/*<license>
C!    Copyright (C) 1996, 1997, 1998, 2001, 2007, 2009 State of California,
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
/**
 * Channel is a Waterbody which has two nodes and a direction of
 * flow between those nodes. In addition it has a length and other
 * properties such as cross-sections.
 *
 * @author Nicky Sandhu
 * @version $Id: Channel.java,v 1.4.6.1 2006/04/04 18:16:24 eli2 Exp $
 */
public class Channel extends Waterbody{
	/**
	   *  a constant for universal swimming velocity.
	   */
	public static float[]uSwimVelParameters = null;
	
  /**
   *  a constant for vertical velocity profiling.
   */
  public final static float VONKARMAN = 0.4f;
  /**
   *  local index of up stream node
   */
  public final static int UPNODE = 0;
  /**
   *  local index of down stream node
   */
  public final static int DOWNNODE = 1;
  /**
   *  a constant defining the resolution of velocity profile
   */
  public final static int MAX_PROFILE = 1000;
  /**
   *  an array of coefficients for profile
   */
  
  public static float[] vertProfile = new float[Channel.MAX_PROFILE];
  /**
   *  use vertical profile
   */
  public static boolean useVertProfile;
  /**
   *  use transverse profile
   */
  public static boolean useTransProfile;
  
  /**
   *  sets fixed information for Channel
   */
  public Channel(int nId, int gnId,
                 int[] xSIds, float len,
                 int[] nodeIds, float[] xSectDist){

    super(Waterbody.CHANNEL, nId, nodeIds);
    length = len;
    //set #of xSections and the idArray
    nXsects = xSIds.length;
    xSArray = new XSection[nXsects];
    xSectionIds = xSIds;
    xSectionDistance = xSectDist;
    
    widthAt = new float[getNumberOfNodes()];
    areaAt = new float[getNumberOfNodes()];
    depthAt = new float[getNumberOfNodes()];
    stageAt = new float[getNumberOfNodes()];
    
  }
  public boolean equals(Channel chan){
	  if (chan.getEnvIndex() == this.getEnvIndex())
		  return true;
	  return false;
  }
  
  /**
   *  Gets the length of Channel
   */
  public final float getLength(){
    return (length);
  }
  
  /**
   *  Gets the width of the Channel at that particular x position
   */
  public final float getWidth(float xPos){
    float alfx = xPos/length;
    return (alfx*widthAt[1] + (1-alfx)*widthAt[0]);
  }
  
  /**
   *  Gets the depth of the Channel at that particular x position
   */
  public final float getDepth(float xPos){
    float depth = 0.0f;
    float alfx = xPos/length;
    
    depth=alfx*depthAt[DOWNNODE] + (1-alfx)*depthAt[UPNODE];
    return depth;
  }
  
  /**
   *  Gets the depth of the Channel at that particular x position
   */
  public final float getStage(float xPos){
    float stage = 0.0f;
    float alfx = xPos/length;
    
    stage = alfx*stageAt[DOWNNODE] + (1-alfx)*stageAt[UPNODE];
    return stage;
  }
  
  /**
   *  Gets the velocity of water in Channel at that particular x,y,z position
   */
  //TODO never been used, clean up
  /*
  public final float getVelocity(float xPos, float yPos, float zPos){
    // returns v >= sign(v)*0.001
    float v = getAverageVelocity(xPos);
    // calculate vertical/ transverse profiles if needed..
    float vp=1.0f, tp=1.0f;
    if(useVertProfile) vp = calcVertProfile(zPos, getDepth(xPos));
    if(useTransProfile) tp = calcTransProfile(yPos, getWidth(xPos));
    return (v*vp*tp);
  }
  */
  
  /**
   *  A more efficient calculation of velocity if average velocity, width and
   *  depth has been pre-calculated.
   */
  public final float getVelocity(float xPos, float yPos, float zPos,
                                 float averageVelocity, float width, float depth){
	float vp=1.0f, tp=1.0f;
    if(useVertProfile) vp = calcVertProfile(zPos, depth);
    if(useTransProfile) tp = calcTransProfile(yPos, width);
    return  (averageVelocity*vp*tp);
  }
  public float getSwimmingVelocity(float particleMeanSwimmingVelocity){
	  if (_swimVelParameters == null){
		  if (uSwimVelParameters == null)
			  return 0.0f;
		  else{
			  if (uSwimVelParameters.length < 3)
				  PTMUtil.systemExit("The mean and standard deviations of the swimming velocity are not properly set, check the behavior input file, system exit.");
			  return particleMeanSwimmingVelocity +  uSwimVelParameters[2]*((float)PTMUtil.getNextGaussian());
		  }
	  }
	  if (_swimVelParameters.length < 3)
		  PTMUtil.systemExit("The mean and standard deviations of the swimming velocity are not properly set, check the behavior input file, system exit.");
	  return particleMeanSwimmingVelocity + _swimVelParameters[2]*((float)PTMUtil.getNextGaussian()); 
  }
  // This more general function is for SwimInputs: it can be maintained a bit easier. 
  public float getParticleMeanValue(String what){
	  if (what.equalsIgnoreCase("SwimmingVelocity"))
		  return getParticleMeanSwimmingVelocity();
	  else if(what.equalsIgnoreCase("RearingHoldingTime"))
		  // the particle holding time returned is actually particle re-active time
		  return getParticleRearingHoldingTime();
	  else
		  PTMUtil.systemExit("don't know what to do with " + what);
	  return 0.0f;
  }
  private float getParticleMeanSwimmingVelocity(){
	  if (_swimVelParameters == null){
		  if (uSwimVelParameters == null)
			  return 0.0f;
		  else
			  return getMeanSwimVel(uSwimVelParameters);
	  }
	  return getMeanSwimVel(_swimVelParameters);
		  //TODO clean up
		  /*
		  else{
			  if (uSwimVelParameters.length < 3)
				  PTMUtil.systemExit("The mean and standard deviations of the swimming velocity are not properly set, check the behavior input file, system exit.");
			  return uSwimVelParameters[0] +  uSwimVelParameters[1]*((float)PTMUtil.getNextGaussian());
		  }
		  
	  }
	  
	  if (_swimVelParameters.length < 3)
		  PTMUtil.systemExit("The mean and standard deviations of the swimming velocity are not properly set, check the behavior input file, system exit.");
	  return _swimVelParameters[0] + _swimVelParameters[1]*((float)PTMUtil.getNextGaussian());  
	  */
  }
  private float getMeanSwimVel(float[] parameters){
	  if (parameters.length < 3)
		  PTMUtil.systemExit("The mean and standard deviations of the swimming velocity are not properly set, check the behavior input file, system exit.");
	  return parameters[0] + parameters[1]*((float)PTMUtil.getNextGaussian());  
  }
  private float getParticleRearingHoldingTime(){
	  // this if block is a must because for channel group ALL parameter is stored in uSwimVelParameters as static variable
	  if (_swimVelParameters == null){
		  if (uSwimVelParameters == null)
			  return 0.0f;
		  else
			  return getHoldingTime(uSwimVelParameters);
	  }
	  return getHoldingTime(_swimVelParameters);
	  //TODO clean up
		  /*
		  else{
			  if (uSwimVelParameters.length < 4)
				  PTMUtil.systemExit("The particle raring holding time are not properly set, check the behavior input file, system exit.");
			  float holdingTime = -uSwimVelParameters[3]*(float)Math.log(PTMUtil.getRandomNumber());
			  if (holdingTime < 0)
				  PTMUtil.systemExit("got a negative rearing holding time, which is imposible, system exit.");
			  return holdingTime+Globals.currentModelTime;   
		  }
		  
	  }
	  if (_swimVelParameters.length < 4)
		  PTMUtil.systemExit("The particle raring holding time are not properly set, check the behavior input file, system exit.");
	  float holdingTime = -_swimVelParameters[3]*(float)Math.log(PTMUtil.getRandomNumber());
	  if (holdingTime < 0)
		  PTMUtil.systemExit("got a negative rearing holding time, which is imposible, system exit.");
	  return holdingTime+Globals.currentModelTime; 
	  */  
  }
  private float getHoldingTime(float [] parameters){
	  if (parameters.length < 4)
		  PTMUtil.systemExit("The particle raring holding time are not properly set, check the behavior input file, system exit.");
	  // because PTMUtil.getRandomNumber() could never be exact 0 or 1, log(PTMUtil.getRandomNumber()) should be OK
	  float holdingTime = -parameters[3]*(float)Math.log(PTMUtil.getRandomNumber());
	  if (holdingTime < 0)
		  PTMUtil.systemExit("got a negative rearing holding time, which is imposible, system exit.");
	  return holdingTime+Globals.currentModelTime;
  }
  public float[] getSwimVelParameters(){
	  if (_isSwimVelParametersSet)
  		return  _swimVelParameters;
	  return  uSwimVelParameters;
  }
  public void setSwimVelParameters(float[] sv){
	  _swimVelParameters = sv;
	  _isSwimVelParametersSet = true;
  }
  /**
   *  the flow at that particular x position
   */
  public final float getFlow(float xPos){
    float flow = 0.0f;
    float alfx = xPos/length;
    
    flow = alfx*flowAt[DOWNNODE] + (1-alfx)*flowAt[UPNODE];
    return flow;
  }
  
  /**
   *  Gets the type from particle's point of view
   */
  @Override
  public int getPTMType(){
    return Waterbody.CHANNEL;
  }
  
  /**
   *  Returns the hydrodynamic type of Channel
   */
  public int getHydroType(){
    return FlowTypes.channell;
  }
  
  /**
   *  Gets the EnvIndex of the upstream node
   */
  public final int getUpNodeId(){
    return(getNodeEnvIndex(UPNODE));
  }
  public final Node getUpNode(){
	  return getNode(UPNODE);
  }
  /**
   *  Gets the EnvIndex of the down node
   */
  public final int getDownNodeId(){
    return(getNodeEnvIndex(DOWNNODE));
  }
  public final Node getDownNode(){
	  return getNode(DOWNNODE);
  }
  /**
   *  Gets the Transverse velocity A coefficient
   */
   public float getTransverseACoef(){
     return Globals.Environment.pInfo.getTransverseACoef();
   }
   
  /**
   *  Gets the Transverse velocity B coefficient
   */
   public float getTransverseBCoef(){
     return Globals.Environment.pInfo.getTransverseBCoef();
   }
   
  /**
   *  Gets the Transverse velocity A coefficient
   */
   public float getTransverseCCoef(){
     return Globals.Environment.pInfo.getTransverseCCoef();
   }
   
  /**
   *  Return flow direction sign
   *  INFLOW (flow into water body) = 1 if node is upstream node
   *  OUTFLoW (flow out water body) = -1 if downstream node
   *  in tidal situation, if flow reverses (flow from downstream), 
   *  flow at down node will be multiplied by -1 to be positive
   *  flow at down node will stay negative
   */
  public int flowType( int nodeId ){
    if (nodeId == UPNODE) 
      return INFLOW;
    else if (nodeId == DOWNNODE) 
      return OUTFLOW;
    else{
      throw new IllegalArgumentException();
    }
  }
  // channel Inflow is channel inflow + swimming flow
  // this method uses a constant mean swimming flow
  public float getInflow(int nodeEnvId){
	  int nodeId = getNodeLocalIndex(nodeEnvId);
		//at gate flow == 0
		if (Math.abs(flowAt[nodeId]) < Float.MIN_VALUE)
			return 0.0f;
		if (flowType(nodeId) == OUTFLOW)
		  return -1.0f*flowAt[nodeId];
		return flowAt[nodeId];
	  // return flow without swimming flow so commented this line out.
	  //return getInflow(nodeEnvId, getMeanSwimmingVelocity());
  } 
  // this channel doesn't know the exact value of the swimming velocity.  
  // SV has to be passed from a particle
  public float getInflowWSV(int nodeEnvId, float sv){
	int nodeId = getNodeLocalIndex(nodeEnvId);
	//at gate flow == 0
	if (Math.abs(flowAt[nodeId]) < Float.MIN_VALUE)
		return 0.0f;
	if (flowType(nodeId) == OUTFLOW)
	  return -1.0f*(flowAt[nodeId]+sv*getFlowArea(length));
	return flowAt[nodeId]+sv*getFlowArea(0.0f);
  }
  public boolean isAgSeep(){ return false;}
  public boolean isAgDiv(){ return false;}
  /**
   *  vertical profile multiplier
   */
  private final float calcVertProfile(float z, float depth){
    float zfrac = z/depth*(MAX_PROFILE-1);
    return Math.max(0.0f, vertProfile[(int)zfrac]);
  }
  
  /**
   *  transverse profile multiplier
   */
  private final float calcTransProfile(float y, float width){
    float yfrac = 2.0f*y/width;
    float yfrac2 = yfrac*yfrac;
    float a = getTransverseACoef();
    float b = getTransverseBCoef();
    float c = getTransverseCCoef();
    return a+b*yfrac2+c*yfrac2*yfrac2; // quartic profile across Channel width
  }
  
  /**
   *  returns the number of cross sections
   */
  public final int getNumberOfXSections(){
    return(nXsects);
  }
  
  /**
   *  Gets the EnvIndex of cross sections given the local index of the
   *  cross section
   */
  public final int getXSectionEnvIndex(int localIndex){
    return(xSectionIds[localIndex]);
  }
  
  /**
   *  Sets pointer information for XSection pointer array
   */
  public final void setXSectionArray(XSection[] xSPtrArray){
    for(int i=0; i<nXsects; i++){
      xSArray[i] = xSPtrArray[i];
      //fill up regular XSection with additional information
      if (xSArray[i].isIrregular() == false){
        xSArray[i].setDistance(xSectionDistance[i]);
        xSArray[i].setChannelNumber(getEnvIndex());
      }//end if
    }//end for
    // sort by ascending order of distance...
    sortXSections();
  }
  
  /**
   *  Returns a pointer to specified XSection
   */
  public final XSection getXSection(int localIndex){
    return(xSArray[localIndex]);
  }
  
  /**
   *  Set depth information
   */
  public final void setDepth(float[] depthArray){
    depthAt[UPNODE] = depthArray[0];
    depthAt[DOWNNODE] = depthArray[1];
    if (Globals.currentModelTime == Globals.Environment.getStartTime()){
      depthAt[UPNODE] = depthAt[UPNODE]/0.5f;
      depthAt[DOWNNODE] = depthAt[DOWNNODE]/0.5f;
    }
  }
  
  /**
   *  Set depth information
   */
  public final void setStage(float[] stageArray){
    stageAt[UPNODE] = stageArray[0];
    stageAt[DOWNNODE] = stageArray[1];
    if (Globals.currentModelTime == Globals.Environment.getStartTime()){
      stageAt[UPNODE] = stageAt[UPNODE]/0.5f;
      stageAt[DOWNNODE] = stageAt[DOWNNODE]/0.5f;
    }
  }
  
  /**
   *  Set area information
   */
  public final void setArea(float[] areaArray){
    areaAt[UPNODE] = areaArray[0];
    areaAt[DOWNNODE] = areaArray[1];
    if (Globals.currentModelTime == Globals.Environment.getStartTime()){
      areaAt[UPNODE] = areaAt[UPNODE]/0.6f;
      areaAt[DOWNNODE] = areaAt[DOWNNODE]/0.6f;
    }
    widthAt[UPNODE] = areaAt[UPNODE]/depthAt[UPNODE];
    widthAt[DOWNNODE] = areaAt[DOWNNODE]/depthAt[DOWNNODE];
  }
  
 // channel direction and confusion constant are only calculated and updated once during a user defined number of tidal cycles for each channel.  
 // the period of the tidal cycles is the PREVIOUS, not current. 
  public void setChanDir(int chanDir){
	  _chanDir = chanDir;
  }
  public float getChanDir(){
	  return _chanDir;
  }
  
  public void setConfusionConst(double confusionConst){
	  _confusionConst = confusionConst;
  }
  public double getProbConfusion(){
	  return _confusionConst;
  }
  /**
   *  Get average velocity
   */
  //TODO clean up this method is never used and have run time errors
  /*
  public final float getAverageVelocity(float xPos){
    int upX = 0, downX = 1;
    downX = getDownSectionId(xPos);
    upX = downX-1;
    float v;
    float alfx = xPos/length;
    // 0 for upX and 1 for downNode
    velocityAt[upX] = calcVelocity(flowAt[upX], 0);
    velocityAt[downX] = calcVelocity(flowAt[downX], length);
    v = alfx*velocityAt[downX] + (1-alfx)*velocityAt[upX];
    //? what if velocity is negative due to negative flows??
    if (Math.abs(v)< PTMUtil.EPSILON) return v/Math.abs(v)*Math.max(0.001f,Math.abs(v));
    else return 0.001f;
  }
  */
  
  /**
   *  Get the flow area
   */
  public final float getFlowArea(float xpos){
    return getDepth(xpos)*getWidth(xpos);
  }
  
  /**
   *  An efficient way of calculating all Channel parameters i.e.
   *  length, width, depth, average velocity and area all at once.
   */
  public final void updateChannelParameters(float xPos, 
                                            float [] channelLength,
                                            float [] channelWidth,
                                            float [] channelDepth,
                                            float [] channelVave,
                                            float [] channelArea){
    channelLength[0] = this.length;
    
    float alfx = xPos/this.length;
    float nalfx = 1.0f - alfx;
    
    channelDepth[0] = alfx*depthAt[DOWNNODE] + nalfx*depthAt[UPNODE];
    channelWidth[0] = alfx*widthAt[DOWNNODE] + nalfx*widthAt[UPNODE];
    channelArea[0] = channelDepth[0]*channelWidth[0];
    
    float Vave = (alfx*flowAt[DOWNNODE] + nalfx*flowAt[UPNODE])/channelArea[0];
    
    if (Vave < 0.001f && Vave > -0.001f){
      if (Math.abs(Vave) < Float.MIN_VALUE)
    	  Vave = 0.001f; // if velocity is 0 return a positive 0.001
      else
    	  Vave = Vave/Math.abs(Vave)*0.001f;
    }
    
    channelVave[0] = Vave;
  }
  
  /**
   *  calculate profile
   */
  public final static void constructProfile(){
    vertProfile[0] = (float) (1.0f + 0.1f*(1.0f + Math.log((0.01f)/MAX_PROFILE))/VONKARMAN);
    for(int i=1; i<MAX_PROFILE; i++)
      vertProfile[i] = (float) (1.0f + (0.1f/VONKARMAN)*(1.0f + Math.log(((float)i)/MAX_PROFILE)));
  }
  public void setOutputDistance(int distance){ _outputChannelDist = distance;}
  public int getOutputDistance(){return _outputChannelDist;}
  /**
   *  Number of cross sections
   */
  private int nXsects;
  /**
   *  Array of XSection object indices contained in this Channel
   */
  private int[] xSectionIds;
  /**
   *  Pointers to XSection objects contained in this Channel
   */
  private XSection[] xSArray;
  /**
   *  Array containing distance of cross sections from upstream end
   */
  private float[] xSectionDistance;
  /**
   *  Length of Channel
   */
  private float length;
  /**
   *  Area of Channel/reservoir
   */

  /**
   *  Flow, depth, velocity, width and area information read from tide file
   */
  private float[] areaAt;
  private float[] depthAt;
  private float[] stageAt;
  private String _chanGroup = null;
  //[0]: const swimming velocity; [1]: STD for particles; [2]: STD for time steps of each particle
  private float[] _swimVelParameters = null;
  private boolean _isSwimVelParametersSet = false;
  // channel distance where a particle's travel time needs to be output
  private int _outputChannelDist = 0;
  private int _chanDir = 1;
  private double _confusionConst = 0;
  /**
   *  Bottom elevation of Channel or reservoir
   */

  //  private static final float a=1.62f,b=-2.22f,c=0.60f;
 
  //TODO clean up never be used
  /*
  private final float calcVelocity(float flow, float xpos){
    return flow/getFlowArea(xpos);
  }
  */
  
  /**
   *  
   */
  //TODO clean up this method is never used and has run time errors
  /*
  private final int getDownSectionId(float xPos){
    //check distance vs x till distance of XSection > xPos
    //that XSection mark it as downX and the previous one as upX
    boolean notFound = true;
    int sectionNumber = -1;
    
    while( (sectionNumber < nXsects) && notFound){
      sectionNumber++;
      if (PTMUtil.floatNearlyEqual(xPos,0.0f)){
        sectionNumber = 1;
        notFound = false;
      }
      if (PTMUtil.floatNearlyEqual(xPos,length)){
        sectionNumber = nXsects-1;
        notFound = false;
      }
      System.err.println("nXsects:"+nXsects+"  "+sectionNumber);
      if (xPos < xSArray[sectionNumber].getDistance()){
        notFound = false;
      }
    }//end while
    return (sectionNumber);
  }
  */
  private final void sortXSections(){
    int i,j;
    float currentSection;
    XSection xSPtr;
    boolean Inserted = false;
    
    for(j=1; j<nXsects; j++){
      currentSection=xSArray[j].getDistance();
      xSPtr=xSArray[j];
      i=j-1;
      Inserted = false;
      
      while(i>=0 && !Inserted){
        if(xSArray[i].getDistance() <= currentSection) {
          Inserted = true;
          xSArray[i+1].setDistance(currentSection);
          xSArray[i+1]=xSPtr;
        }//end if
        else {
          xSArray[i+1].setDistance(xSArray[i].getDistance());
          xSArray[i+1]=xSArray[i];
        }//end else
        i--;
      }//end while
      if (!Inserted) {
        xSArray[0].setDistance(currentSection);
        xSArray[0]=xSPtr;
      }
    }//end for
  }
  public void setChanGroup(String group){ 
	  _chanGroup = group;
  }
  public String getChanGroup(){ return _chanGroup;}
}

