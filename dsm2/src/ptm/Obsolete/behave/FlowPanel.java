//    Copyright (C) 1996 State of California, Department of Water
//    Resources.
//
//    Delta Simulation Model 2 (DSM2): A River, Estuary, and Land
//    numerical model.  No protection claimed in original FOURPT and
//    Branched Lagrangian Transport Model (BLTM) code written by the
//    United States Geological Survey.  Protection claimed in the
//    routines and files listed in the accompanying file "Protect.txt".
//    If you did not receive a copy of this file contact 
//    Tara Smith, below.
//
//    This program is licensed to you under the terms of the GNU General
//    Public License, version 2, as published by the Free Software
//    Foundation.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, contact Tara Smith, below,
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
//    Tara Smith
//    California Dept. of Water Resources
//    Division of Planning, Delta Modeling Section
//    1416 Ninth Street
//    Sacramento, CA  95814
//    916-653-9885
//    tara@water.ca.gov
//
//    or see our home page: http://baydeltaoffice.water.ca.gov/modeling/deltamodeling/

package DWR.DMS.PTM.behave;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

/**
 * This class produces the GUI panel which interfaces with FlowElement.
 * <br>
 * 
 * @author Aaron Miller
 * @version $Id: FlowPanel.java,v 1.2 2000/08/07 17:05:05 miller Exp $
 */

public class FlowPanel extends JPanel implements FocusListener, ItemListener {

  /**
    *  panel that contains all fields
    */
  JPanel mainPanel;

  /**
    *  a pointer to the current field
    */
  JTextField currentField;

  /**
    *  Behavior Fields used for displaying and retrieving information
    */
  //  BehaviorField field1, field2, field3;

  /**
    *  a pointer to the data contained by PhysicalElement 
    */
  FlowElement thisElement;

  /**
    *  is true if error message is present. Used to eliminate circular 
    *  error messages
    */
  boolean optionOn;

  /**
    *  is a flag used if text field contains data that does not convert 
    *  from String to float.
    */
  boolean focusable;

  JPanel buttonPanel;
  FlowTable fTable;
  Vector rowData;
  Vector columnData;
  String columns [] = {"Velocity","Start Time","End Time"};
  String rows [] = {"","",""};
  private static int NUM_ROWS = 2;

  /**
    *  Constructs a FlowPanel
    */
  //  public FlowPanel (FlowElement element){
  public FlowPanel (FlowElement element){
    mainPanel = new JPanel(false);

    fTable = new FlowTable("Positioning for the depth (0 = bottom, 100 = top)");

    thisElement = element;

    mainPanel.setLayout(new GridLayout(2,1));
    mainPanel.add(fTable);
    add(mainPanel);
    getParams();
    
  }

  /**
    *  Passes information from Behavior Fields to PhysicalElement
    */
  public void setParams() {
    thisElement.setVerticalPosition(fTable.getTableContents());
  }

  /**
    *  Gets information from PhysicalElement and passes to Behavior Fields
    */
  public void getParams() {
    fTable.setTableContents(thisElement.getVerticalPosition());
    // testing
    //    thisElement.dumpArray();
  }

  /**
    *  Tests the text in TextField for the ability to convert to a floating point number.
    *  If conversion fails a message box is displayed.
    */
  public void testNumeric(JTextField field) {
    String str = field.getText().trim();
    if (str.length()>0){
      focusable = false;
      try {
	float tmp = (float) new Float (str).floatValue();
      } catch (Exception e){
	if (! optionOn){
	  optionOn = true;
	  JOptionPane.showMessageDialog(this,"A REAL Number is Required for this Field!","ERROR", JOptionPane.ERROR_MESSAGE);
	  currentField = field;
	  focusable = true;
	  optionOn = false;
	}
      }
    }
  }

  /**
    *  Method FocusListener
    */
  public void focusGained (FocusEvent evt) { 
      System.out.println("Gained");
      if (focusable) {
	currentField.selectAll();
	currentField.requestFocus();
      }
    
  } 

  /**
    *  Method FocusListener
    */
  public void focusLost (FocusEvent evt) {
    if(evt.getSource() instanceof JTextField){
      System.out.println("Lost");
      if (! evt.isTemporary())
	testNumeric((JTextField) evt.getSource());
    }
  } 

  /**
    *  Method ItemListener
    */
  public void itemStateChanged (ItemEvent evt) {
      System.out.println("Item Gained");
      if (focusable) {
	currentField.selectAll();
	currentField.requestFocus();
      }
    
  }
}