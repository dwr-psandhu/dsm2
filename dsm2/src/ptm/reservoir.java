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
/**
 * Reservoir is a waterbody with a large volume. A reservoir
 * is modeled as storage for water with no velocity fields within it.
 *
 * @author Nicky Sandhu
 * @version $Id: reservoir.java,v 1.2 2000/08/07 17:00:35 miller Exp $
 */
public class reservoir extends waterbody{
  /**
   *  sets fixed information for reservoir
   */
public reservoir(int nId, int hId, String wbName, 
		 float resArea, float botelv, 
		 int[] nodeArray){
  super(waterbody.RESERVOIR, nId, nodeArray);
  name = wbName;
  this.area = resArea;
  bottomElevation = botelv;
}
  /**
   *  gets direction of flow
   */
public  int flowType( int nodeId ){
  return INFLOW;
}
  /**
   *  Returns the hydrodynamic type of reservoir
   */
public  int getHydroType(){
  return flowTypes.reservoirr;
}
  /**
   *  Gets the total volume of water in reservoir else returns 0.
   */
public final float getTotalVolume(float timeStep){
  return ( volume );
}
  /**
   *  Gets the total volume outflow to local nodeId in a certain time step
   */
public final float getVolumeOutflow(int nodeId, float timeStep){
    return ( flowAt[nodeId]*timeStep );
}
  /**
   *  Set reservoir volume
   */
public final void setVolume(float currentVolume){
  volume = currentVolume;
}
  /**
   *  Set depth information
   */
public final void setDepth(float[] depthArray){
  depthAt[0] = depthArray[0];
}
  /**
   *  string containing the name
   */
private String name;
  /**
   *  Area of channel/reservoir
   */
private float area;
  /**
   *  Volume of reservoir
   */
private float volume;
  /**
   *  Bottom elevation of channel or reservoir
   */
private float bottomElevation;
}

