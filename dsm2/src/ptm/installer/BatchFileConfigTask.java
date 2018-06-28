import java.io.*;
import java.util.*;
import com.sun.wizards.core.*;
import com.sun.wizards.services.*;

/**
 * The generic task is a sample task that does
 * nothing.  The task is initialized with the
 * amount of time the task should take.  The
 * task merely waits for the specified time.
 */
public class BatchFileConfigTask extends Task implements Serializable
{

      public static final String SEQUENCE_NAME = "Batch File Configuration";
  /**
   * A flag indicating whether or not this task has been canceled.
   */
  private transient boolean canceled = false;

  /**
   * Creates a CustomTask that waits the specified
   * length of time, in seconds.
   *
   * @param completionTime	The number of seconds this task
   *				takes to complete.
   */
  public BatchFileConfigTask()
    {
    }

  /**
   * Perform this task.  This method merely waits the amount
   * of time specified in the constructor.
   */
  public void perform()
    {
      setProgress(5);
      try {
	writeOutWinBatch();
      }catch(IOException ioe){
	System.err.println("Error installing PTM");
      }
      setProgress(100);
    }
  /**
    *
    */
  static String cleanUpEscapeChar(String dir){
    StringBuffer sb1 = new StringBuffer(dir);
    StringBuffer sb2 = new StringBuffer(dir.length());
    char ls = '\\';
    int i1=0,i2=0; 
    boolean lastCharEscape = false;
    while( true ){
      if ( i1 >= sb1.length() ) break;
      if ( sb1.charAt(i1) == ls ) {
	if (lastCharEscape){
	  i1++;
	  continue;
	}
	sb2.insert(i2,'/');
	lastCharEscape = true;
      } else {
	sb2.insert(i2,sb1.charAt(i1));
	lastCharEscape = false;
      }
      i1++;
      i2++;
    }
    return sb2.toString();
  }
  /**
    *
    */
  public void writeOutWinBatch() throws IOException{
    String idir= com.sun.install.products.InstallConstants.currentInstallDirectory;
    WizardState ws = getWizardState();
    idir = (String) ws.getData(idir);
    String homeDir = cleanUpEscapeChar(idir);
    String fs = System.getProperty("file.separator");
    String classpath = "\""+idir+fs+"lib"+fs+"ptm.jar;"+idir+fs+"lib"+
      fs+"COM.jar;"+idir+fs+"lib"+fs+"edu.jar;"+
      idir+fs+"lib"+fs+"xml.jar;"+idir+fs+"lib"+fs+"swingall.jar;\"";
//    String options = "-mx50m -Dptm.home=\""+homeDir+"\"";
    String options = "-ss1m -mx48m";
    String startString = null;
    if ( System.getProperty("os.name").indexOf("NT") >= 0 )
      startString = "start " ;
    else
      startString = "";
    PrintWriter pw = new PrintWriter(new FileWriter(idir+"/bin/ptm.bat"));
    pw.println("@echo off");
    pw.println("rem ###############");
    pw.println("rem Batch file for running ptm client");
    pw.println("rem ###############");
    pw.println("rem auto generated by install script");
    pw.println("rem ###############");
    pw.println("rem starting ptm");
    pw.println("rem ###############");
    pw.println("set path="+homeDir+fs+"lib;%path%");
    pw.println("jre " +options+ " -cp "+classpath+" DWR.DMS.PTM.mainPTM ");
    pw.close();
    pw = new PrintWriter(new FileWriter(idir+"/bin/behave.bat"));
    pw.println("@echo off");
    pw.println("rem ###############");
    pw.println("rem Batch file for running behavior editor");
    pw.println("rem ###############");
    pw.println("rem auto generated by install script");
    pw.println("rem ###############");
    pw.println("rem starting behavior editor");
    pw.println("rem ###############");
    pw.println("set path="+homeDir+fs+"lib;%path%");
    pw.println("jre " +options+ " -cp "+classpath+" DWR.DMS.PTM.behave.mainGUI ");
    pw.close();
  }
  /**
   * Cancel this task.
   */
  public void cancel()
  {
    this.canceled = true;
  }

  /**
   * Add the runtime class requirements to the specified vector.
   * @param resourceVector The vector containing all runtime resources for this wizard.  
   */
  public void addRuntimeResources(Vector resourceVector)
  {
    resourceVector.addElement(new String[] {null, "BatchFileConfigTask"});
  }
}
