/**
 * 
 */
package DWR.DMS.PTM;

/**
 * @author xwang
 *
 */
public class SalmonBasicSurvivalBehavior implements SalmonSurvivalBehavior {
	private boolean DEBUG = false;
	//private Map<String, Double> _survivalRates = null;
	private SurvivalInputs _survivalIn;

	/**
	 * 
	 */
	public SalmonBasicSurvivalBehavior() {
		// TODO Auto-generated constructor stub
	}
	/**
	 * 
	 */
	public SalmonBasicSurvivalBehavior(SurvivalInputs survivalIn) {
		_survivalIn = survivalIn;
	}
	
	/* (non-Javadoc)
	 * @see DWR.DMS.PTM.SurvivalBehavior#isSurvived(DWR.DMS.PTM.Particle)
	 */
	@Override
	//TODO this function need to be worked on
	// read doug's code and Russ' paper
	public void isSurvived(Particle p, float x, float t) {
		if (_survivalIn.getSurvivalRates() == null){
			p.isDead = false;
			return;
		}
		// timeInterval in days
		// timeToAdvance in seconds
		double timeInterval = t/(60d*60d*24d);
		if (timeInterval<0)
			PTMUtil.systemExit("in particle survial behavior, expect positive time interval but get:" + timeInterval);
		double survivalProbability = 0;
		Waterbody wb = p.wb;
		Double rate = null;
		if ((wb.getType() == Waterbody.CHANNEL)
				&& ((rate = _survivalIn.getSurvivalRate(p.wb.getEnvIndex()))!= null)){
			survivalProbability = Math.exp(rate*timeInterval*(-1.0));
			if(DEBUG){
				System.out.println("id:"+p.Id+ " rate:"+ rate);
				System.out.println("channel:"+wb.getEnvIndex()+ " timeInterval:"+timeInterval*60d*60d*24d+"  survival probability:"+survivalProbability);
			}	
		}
		else
			survivalProbability = 1;
		if (survivalProbability<PTMUtil.getNextGaussian()){
			p.isDead = true;	
			if(DEBUG) 
				System.out.println("channel:"+PTMHydroInput.getExtFromIntChan(((Channel) wb).getEnvIndex())
				+"  id:" + p.Id + "  timeInterval:"+timeInterval*24*60*60+"  survival probability:"+ survivalProbability+"  p.isDead:"+p.isDead);	
		}
		
	}
	/*
	 * get the maximum distance a particle traveled from the entrance node
	 */
	public float getXofXTSurvival(Channel ch, Node nd, float x, float maxDist){
		int sign = (isDownNode(ch, nd)? -1: 1);
		float overHead = (isDownNode(ch, nd)? ch.getLength(): 0.0f);
		float currDist = x*sign + overHead;
		return ((maxDist < currDist)? currDist: maxDist);			 
	}
	boolean isDownNode(Channel ch, Node nd){return (ch.getDownNodeId() == nd.getEnvIndex());}
	
	//TODO this is fast exp calculation.  should it be used for other PTM calculations?
	/*
	private double exp(double val) {
        final long tmp = (long) (1512775 * val + 1072632447);
        return Double.longBitsToDouble(tmp << 32);
    }
    */

}
