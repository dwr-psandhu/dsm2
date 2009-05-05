/*
    Copyright (C) 1996-2000 State of California, Department of 
    Water Resources.

    DSM2-PTM : Delta Simulation Model 2 - Particle Tracking Model module.
        Maintained by: Aaron Miller
    California Dept. of Water Resources
    Division of Planning, Delta Modeling Section
    1416 Ninth Street
    Sacramento, CA 95814
    (916)-653-4603
    miller@water.ca.gov

    Send bug reports to miller@water.ca.gov

    This program is licensed to you under the terms of the GNU General
    Public License, version 2, as published by the Free Software
    Foundation.

    You should have received a copy of the GNU General Public License
    along with this program; if not, contact Dr. Paul Hutton, below,
    or the Free Software Foundation, 675 Mass Ave, Cambridge, MA
    02139, USA.

    THIS SOFTWARE AND DOCUMENTATION ARE PROVIDED BY THE CALIFORNIA
    DEPARTMENT OF WATER RESOURCES AND CONTRIBUTORS "AS IS" AND ANY
    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
    PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE CALIFORNIA
    DEPARTMENT OF WATER RESOURCES OR ITS CONTRIBUTORS BE LIABLE FOR
    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
    OR SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA OR PROFITS; OR
    BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
    USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
    DAMAGE.

    For more information about PTM, contact:

    Dr. Paul Hutton
    California Dept. of Water Resources
    Division of Planning, Delta Modeling Section
    1416 Ninth Street
    Sacramento, CA  95814
    916-653-5601
    hutton@water.ca.gov

    or see our home page: http://wwwdelmod.water.ca.gov/

    Send bug reports to miller@water.ca.gov or call (916)-653-7552

*/
package DWR.DMS.PTM.tools.image;
import java.awt.*;
/**
 * @author Aaron Miller
 * @version $Id: BarrierOperGraphic.java,v 1.2 2000/08/07 17:15:19 miller Exp $
 * 
 */

public class BarrierOperGraphic extends GraphicElement{

  public void drawElement(Graphics g, int x, int y, int w, int h, int rot){
    Graphics2D g2d = (Graphics2D) g;
    int xpos = x-(w/2);
    int ypos = y-(h/2);
    double theta = (Math.PI/180.)*rot;
    g2d.rotate(theta,x,y);
    g2d.setColor(getForeGroundColor());
    g2d.fillRect(xpos,ypos,w,h);
    g2d.rotate(-theta,x,y);
  }
  
}