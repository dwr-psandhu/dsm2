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
 * @version $Id: PlotLabel.java,v 1.2 2000/08/07 17:15:21 miller Exp $
 * 
 */

public class PlotLabel{
  Graphics g;
  int pHeight = 100;
  int pWidth = 10;
  Font regularFont = new Font("Tahoma", Font.PLAIN, 12);
  Font bigFont = regularFont.deriveFont(18.0f);
  Font boldFont = regularFont.deriveFont(Font.BOLD);
  Font bigBoldFont = regularFont.deriveFont(Font.BOLD,18.0f);
  Font italicFont = regularFont.deriveFont(Font.ITALIC);
  Font smallItalicFont = regularFont.deriveFont(Font.ITALIC,10.0f);

  public PlotLabel(Graphics g){
    this.g = g;
    //    GraphicsEnvironment env = GraphicsEnvironment.getLocalGraphicsEnvironment();
    //    String [] familynames = env.getAvailableFontFamilyNames();
    //    for (int i = 0; i < familynames.length; i++){
    //      System.out.println(familynames[i]);
    //    }
    //    setLabelFont(italicFont);
  }

  public void drawLabel (int xpos, int ypos, int type, String label){
    setLabelFont(type);
    g.drawString(label, xpos, ypos);
  }

  public void setLabelColor(Color color){
    g.setColor(color);
  }

  public void setLabelFont(int type){
    switch(type){
    case 1:
      setLabelFont(regularFont);
      break;
    case 2:
      setLabelFont(bigFont);
      break;
    case 3:
      setLabelFont(boldFont);
      break;
    case 4:
      setLabelFont(bigBoldFont);
      break;
    case 5:
      setLabelFont(italicFont);
      break;
    case 6:
      setLabelFont(smallItalicFont);
      break;
    default:
      setLabelFont(regularFont);
    }
  }
  public void setLabelFont(Font font){
    g.setFont(font);
  }
  
}
