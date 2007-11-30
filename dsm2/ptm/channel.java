//    Copyright (C) 1996 State of California, Department of Water
//    Resources.
//
//    Delta Simulation Model 2 (DSM2): A River, Estuary, and Land
//    numerical model.  No protection claimed in original FOURPT and
//    Branched Lagrangian Transport Model (BLTM) code written by the
//    United States Geological Survey.  Protection claimed in the
//    routines and files listed in the accompanying file "Protect.txt".
//    If you did not receive a copy of this file contact Dr. Paul
//    Hutton, below.
//
//    This program is licensed to you under the terms of the GNU General
//    Public License, version 2, as published by the Free Software
//    Foundation.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, contact Dr. Paul Hutton, below,
//    or the Free Software Foundation, 675 Mass Ave, Cambridge, MA
//    02139, USA.
//
//    THIS SOFTWARE AND DOCUMENTATION ARE PROVIDED BY THE CALIFORNIA
//    DEPARTMENT OF WATER RESOURCES AND CONTRIBUTORS "AS IS" AND ANY
//    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//    PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE CALIFORNIA
//    DEPARTMENT OF WATER RESOURCES OR ITS CONTRIBUTORS BE LIABLE FOR
//    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
//    OR SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA OR PROFITS; OR
//    BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
//    USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
//    DAMAGE.
//
//    For more information about DSM2, contact:
//
//    Dr. Paul Hutton
//    California Dept. of Water Resources
//    Division of Planning, Delta Modeling Section
//    1416 Ninth Street
//    Sacramento, CA  95814
//    916-653-5601
//    hutton@water.ca.gov
//
//    or see our home page: http://wwwdelmod.water.ca.gov/

//$Id: channel.java,v 1.4.6.1 2006/04/04 18:16:24 eli2 Exp $
package DWR.DMS.PTM;
import java.lang.*;
/**
 * A channel is a waterbody which has two nodes and a direction of 
 * flow between those nodes. In addition it has a length and other
 * properties such as cross-sections.
 *
 * @author Nicky Sandhu
 * @version $Id: channel.java,v 1.4.6.1 2006/04/04 18:16:24 eli2 Exp $
 */
public class channel extends waterbody{
  /**
   * a constant for vertical velocity profiling.
   */
  public final static float VONKARMAN = 0.4f;
  /**
   * local index of up stream node
   */
  public final static int UPNODE = 0;
  /**
   * local index of down stream node
   */
  public final static int DOWNNODE = 1;
  /**
   * a constant defining the resolution of velocity profile
   */
  public final static int MAX_PROFILE = 1000;
  /**
   *  an array of coefficients for profile
   */
  public static float[] vertProfile = new float[channel.MAX_PROFILE];
  /**
   *  use vertical profile
   */
  public static boolean useVertProfile;
  /**
   *  use transverse profile
   */
  public static boolean useTransProfile;
  /**
   *  sets fixed information for channel
   */
  public channel(int nId, int gnId,
		 int[] xSIds, float len,
		 int[] nodeIds, float[] xSectDist) {
    
    super(waterbody.CHANNEL, nId, nodeIds);
    length = len;
    //set #of xSections and the idArray
    nXsects = xSIds.length;
    xSArray = new xSection[nXsects];
    xSectionIds = xSIds;
    xSectionDistance = xSectDist;
    
    widthAt = new float[getNumberOfNodes()];
    areaAt = new float[getNumberOfNodes()];
    depthAt = new float[getNumberOfNodes()];
    stageAt = new float[getNumberOfNodes()];
    
  }
  /**
   *  Gets the length of channel
   */
  public final float getLength(){
    return(length);
  }
  /**
   *  Gets the width of the channel at that particular x position
   */
  public final float getWidth(float xPos){
    float alfx = xPos/length;
    return(alfx*widthAt[1] + (1-alfx)*widthAt[0]);
  }
  /**
   *  Gets the depth of the channel at that particular x position
   */
  public final float getDepth(float xPos){
    float depth = 0.0f;
    float alfx = xPos/length;
    
    depth=alfx*depthAt[DOWNNODE] + (1-alfx)*depthAt[UPNODE];
    return depth;
  }
  /**
   *  Gets the depth of the channel at that particular x position
   */
  public final float getStage(float xPos){
    float stage = 0.0f;
    float alfx = xPos/length;
    
    stage=alfx*stageAt[DOWNNODE] + (1-alfx)*stageAt[UPNODE];
    return stage;
  }
  /**
   *  Gets the velocity of water in channel at that particular x,y,z position
   */
  public final float getVelocity(float xPos, float yPos, float zPos){
    // returns v >= sign(v)*0.001
    float v = getAverageVelocity(xPos);
    // calculate vertical/ transverse profiles if needed..
    float vp=1.0f, tp=1.0f;
    if(useVertProfile) vp = calcVertProfile(zPos, getDepth(xPos));
    if(useTransProfile) tp = calcTransProfile(yPos, getWidth(xPos));
    return (v*vp*tp);
  }
  /**
   *  A more efficient calculation of velocity if average velocity, width and
   *  depth has been pre-calculated.
   */
  public final float getVelocity(float xPos, float yPos, float zPos,
				 float averageVelocity, float width, float depth){
    float vp=1.0f, tp=1.0f;
    if(useVertProfile) vp = calcVertProfile(zPos, depth);
    if(useTransProfile) tp = calcTransProfile(yPos, width);
    return (averageVelocity*vp*tp);
  }
  /**
   *  the flow at that particular x position
   */
  public final float getFlow(float xPos){
    float flow = 0.0f;
    float alfx = xPos/length;
    
    flow=alfx*flowAt[DOWNNODE] + (1-alfx)*flowAt[UPNODE];
    return flow;
    
  }
  /**
   *  Gets the type from particle's point of view
   */
  public int getPTMType(){
    return waterbody.CHANNEL;
  }
  /**
   *  Returns the hydrodynamic type of channel
   */
  public  int getHydroType(){
    return flowTypes.channell;
  }
  /**
   *  Gets the EnvIndex of the upstream node
   */
  public final int getUpNodeId(){
    return( getNodeId(UPNODE));
  }
  /**
   *  Gets the EnvIndex of the down node
   */
  public final int getDownNodeId(){
    return( getNodeId(DOWNNODE));
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
   *  Returns flow type ie.
   *  inflow if node is upstream node
   *  outflow if downstream node
   */
  public int flowType( int nodeId ){
    if (nodeId == UPNODE) 
      return OUTFLOW;
    else if (nodeId == DOWNNODE) 
      return INFLOW;
    else{
      throw new IllegalArgumentException();
    }
  }
  /**
   *  vertical profile multiplier
   */
  private final float calcVertProfile(float z, float depth){
    float zfrac = z/depth*(MAX_PROFILE-1);
    return Math.max(0.0f, vertProfile[(int)zfrac]);
  }
  /**
   *  transvers profile multiplier
   */
  private final float calcTransProfile(float y, float width){
    float yfrac = 2.0f*y/width;
    float yfrac2=yfrac*yfrac;
    float a = getTransverseACoef();
    float b = getTransverseBCoef();
    float c = getTransverseCCoef();
    return a+b*yfrac2+c*yfrac2*yfrac2; // quartic profile across channel width
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
   *  Sets pointer information for xSection pointer array
   */
  public final void setXSectionArray(xSection[] xSPtrArray){
    for(int i=0; i<nXsects; i++){
      xSArray[i] = xSPtrArray[i];
      //fill up regular xSection with additional information
      if (xSArray[i].isIrregular() == false){
	xSArray[i].setDistance(xSectionDistance[i]);
	xSArray[i].setChannelNumber(getEnvIndex());
      }
    }
    // sort by ascending order of distance...
    sortXSections();
  }
  /**
   *  Returns a pointer to specified xSection
   */
  public final xSection getXSection(int localIndex){
    return(xSArray[localIndex]);
  }
  /**
   *  Set depth information
   */
  public final void setDepth(float[] depthArray){
    depthAt[UPNODE] = depthArray[0];
    depthAt[DOWNNODE] = depthArray[1];
  }
  /**
   *  Set depth information
   */
  public final void setStage(float[] stageArray){
    stageAt[UPNODE] = stageArray[0];
    stageAt[DOWNNODE] = stageArray[1];
  }
  /**
   *  Set area information
   */
  public final void setArea(float[] areaArray){
    areaAt[UPNODE] = areaArray[0];
    widthAt[UPNODE] = areaAt[UPNODE]/depthAt[UPNODE];
    areaAt[DOWNNODE] = areaArray[1];
    widthAt[DOWNNODE] = areaAt[DOWNNODE]/depthAt[DOWNNODE];
  }
  /**
   *  Get average velocity
   */
  public final float getAverageVelocity(float xPos){
    int upX=0, downX=1;
    downX = getDownSectionId(xPos);
    upX = downX-1;
    float v;
    float alfx = xPos/length;
    // 0 for upX and 1 for downNode
    velocityAt[upX] = calcVelocity(flowAt[upX], 0);
    velocityAt[downX] = calcVelocity(flowAt[downX], length);
    v=alfx*velocityAt[downX] + (1-alfx)*velocityAt[upX];
    //? what if velocity is negative due to negative flows??
    if (v!=0) return v/Math.abs(v)*Math.max(0.001f,Math.abs(v));
    else return 0.001f;
  }
  /**
   *  Gets the flow area
   */
  public final float getFlowArea(float xpos){
    return getDepth(xpos)*getWidth(xpos);
  }
  /**
   *  An efficient way of calculating all channel parameters i.e.
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
    
    channelDepth[0]=alfx*depthAt[DOWNNODE] + nalfx*depthAt[UPNODE];
    
    channelWidth[0]=alfx*widthAt[DOWNNODE] + nalfx*widthAt[UPNODE];
    
    channelArea[0] = channelDepth[0]*channelWidth[0];
    float Vave= (alfx*flowAt[DOWNNODE]+nalfx*flowAt[UPNODE])/channelArea[0];
    
    if (Vave < 0.001f && Vave > -0.001f)
      Vave = Vave/Math.abs(Vave)*0.001f;
    
    channelVave[0] = Vave;
  }
  /**
   *  calculate profile
   */
  public final static void constructProfile(){
    vertProfile[0] = (float) (1.0f+0.1f*(1.0f+Math.log((0.01f)/MAX_PROFILE)/VONKARMAN));
    for(int i=1; i< MAX_PROFILE; i++)
      vertProfile[i] = (float) (1.0f+(0.1f/VONKARMAN)*(1.0f+Math.log(((float)i)/MAX_PROFILE)));
  }
  /**
   *  Number of cross sections
   */
  private int nXsects;
  /**
   *  Array of xSection object indices contained in this channel
   */
  private int[] xSectionIds;
  /**
   *  Pointers to xSection objects contained in this channel
   */
  private xSection[] xSArray;
  /**
   *  Array containing distance of cross sections from upstream end
   */
  private float[] xSectionDistance;
  /**
   *  Length of channel
   */
  private float length;
  /**
   *  Area of channel/reservoir
   */
  private float area;
  /**
   *  Flow, depth, velocity, width and area information read from tide file
   */
  private float[] areaAt;
  
  private float[] depthAt;
  
  private float[] stageAt;
  
  
  /**
   *  Bottom elevation of channel or reservoir
   */
  private float bottomElevation;
  //  private static final float a=1.62f,b=-2.22f,c=0.60f;
  
  private final float calcVelocity(float flow, float xpos){
    return flow/getFlowArea(xpos);
  }
  
  private final int getDownSectionId(float xPos){
    //check distance vs x till distance of xSection > xPos
    //that xSection mark it as downX and the previous one as upX
    boolean notFound = true;
    int sectionNumber=-1;
    while( (sectionNumber < nXsects) && notFound){
      sectionNumber++;
      if (Macro.APPROX_EQ(xPos,0.0f)){
	sectionNumber = 1;
	notFound = false;
      }
      if (Macro.APPROX_EQ(xPos,length)){
	sectionNumber = nXsects-1;
	notFound = false;
      }
      if (xPos < xSArray[sectionNumber].getDistance()){
	notFound = false;
      }
    }
    return (sectionNumber);
  }
  
  private final void sortXSections(){
    int i,j;
    float currentSection;
    xSection  xSPtr;
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
	}
	else {
	  xSArray[i+1].setDistance(xSArray[i].getDistance());
	  xSArray[i+1]=xSArray[i];
	}
	i--;
      }
      if (!Inserted) {
	xSArray[0].setDistance(currentSection);
	xSArray[0]=xSPtr;
      }
    }
  }
  
}

