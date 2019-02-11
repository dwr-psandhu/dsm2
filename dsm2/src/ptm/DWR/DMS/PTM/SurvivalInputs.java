/**
 * 
 */
package DWR.DMS.PTM;
import java.io.BufferedWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

/**
 * @author xwang
 *
 */
public class SurvivalInputs {
	/**
	 * 
	 */
	public SurvivalInputs() {
		// TODO Auto-generated constructor stub
	}
	
	public SurvivalInputs(ArrayList<String> inList, String fishType) {
		if (fishType == null)
			PTMUtil.systemExit("No Particle Type! exit.");
		_fishType = fishType;
		if (inList != null){
			/*
			 * !!! a channel can only have at most one start, end, and exchange station.
			 */
			_startStas = new ArrayList<Integer>();
			_startStasDist = new HashMap<Integer, Integer>();
			_groupParas = new HashMap<Integer, ArrayList<Double>>();
			_endStasDist = new HashMap<Integer, Integer>();
			_exchStasDist = new HashMap<Integer, Integer>();
			_groupEndStas = new HashMap<Integer, ArrayList<Integer>>();
			_groupExchStas = new HashMap<Integer, ArrayList<Integer>>();
			_groupArrivals = new HashMap<Integer, Integer>();
			_groupLost = new HashMap<Integer, Integer>();
			_groupSurvival = new HashMap<Integer, Integer>();
			_groupName = new HashMap<Integer, String>();
			_startStaGroup = new HashMap<Integer, Integer>();
			_pReachProb = new HashMap<Integer, Map<Integer, Double>>();
			setSurvivalParameters(PTMUtil.getInputBlock(inList, "SURVIVAL_PARAMETERS", "END_SURVIVAL_PARAMETERS"));
			if(DEBUG){
				for(int ss: _startStas)
					System.err.println("_startStas:"+PTMHydroInput.getExtFromIntChan(ss));
				for (Map.Entry<Integer, Integer> entry: _startStasDist.entrySet())
					System.err.println("_startStasDist:"+PTMHydroInput.getExtFromIntChan(entry.getKey()) + " "+ entry.getValue());
				for (Map.Entry<Integer, ArrayList<Double>> entry: _groupParas.entrySet())
					System.err.println("_groupParas:"+entry.getKey() + " "+ entry.getValue().get(0)+ " "+ entry.getValue().get(1)+ " "+ entry.getValue().get(2));
				for (Map.Entry<Integer, Integer> entry: _endStasDist.entrySet())
					System.err.println("_endStasDist:"+PTMHydroInput.getExtFromIntChan(entry.getKey()) + " "+ entry.getValue());
				for (Map.Entry<Integer, Integer> entry: _exchStasDist.entrySet())
					System.err.println("_exchStasDist:"+PTMHydroInput.getExtFromIntChan(entry.getKey()) + " "+ entry.getValue());
				for (Map.Entry<Integer, Integer> entry: _startStaGroup.entrySet())
					System.err.println("_startStaGroup:"+PTMHydroInput.getExtFromIntChan(entry.getKey()) + " "+ entry.getValue());
				for (Map.Entry<Integer, ArrayList<Integer>> entry: _groupEndStas.entrySet()){
					System.err.println("_groupEndStas:"+entry.getKey());
					for (int ges: entry.getValue())
						System.err.println("_groupEndStas:"+PTMHydroInput.getExtFromIntChan(ges));
				}
				for (Map.Entry<Integer, ArrayList<Integer>> entry: _groupExchStas.entrySet()){
					System.err.println("_groupExchStas:"+entry.getKey());
					for (int ges: entry.getValue())
						System.err.println("_groupExchStas:"+PTMHydroInput.getExtFromIntChan(ges));
				}
			}
		}
		else{
			_doSurvival = false;
			System.err.println("No survival parameters are input, and survival rates will not be calculated.");
		}
	}
	public int getGroupNumber(int startStation){return _startStaGroup.get(startStation);}
	public Map<Integer, ArrayList<Double>> getSurvivalParameterMap(){return _groupParas;}
	public ArrayList<Double> getSurvivalParameters(int groupId){return _groupParas.get(groupId);}
	public ArrayList<Integer> getStartStations(){return _startStas;}
	public ArrayList<Integer> getEndStations(int groupId){return _groupEndStas.get(groupId);}
	public ArrayList<Integer> getExchangeableStations(int groupId){return _groupExchStas.get(groupId);}
	public int getStartStationDistance(int chanNum){return _startStasDist.get(chanNum);}
	public int getEndStationDistance(int chanNum){return _endStasDist.get(chanNum);}
	public int getExchangeableStationDistance(int chanNum){return _exchStasDist.get(chanNum);}
	public boolean isStartChan(int chanId){return _startStas.contains(chanId);}
	public boolean isEndChan(int groupId, int chanId){return _groupEndStas.get(groupId).contains(chanId);}
	public boolean isExchangeChan(int groupId, int chanId){return _groupExchStas.get(groupId).contains(chanId);}
	//public boolean fromUpstream(Particle p){return (p.nd.getEnvIndex() == ((Channel)p.wb).getUpNode().getEnvIndex());}
	//only is...(e.g., isStartChan) == true check... (e.g., checkStart) can be called
	public boolean checkStart(int chanId, float x, boolean fromUpstream){return staReached(chanId, x, _startStasDist, fromUpstream);}
	public boolean checkEnd(int chanId, float x, boolean fromUpstream){return staReached(chanId, x, _endStasDist, fromUpstream);}
	public boolean checkExchange(int chanId, float x, boolean fromUpstream){return staReached(chanId, x, _exchStasDist, fromUpstream);}
	public boolean isStart(int chanId, float x, boolean fromUpstream){return isStartChan(chanId) && checkStart(chanId, x, fromUpstream);}
	public boolean isEnd(int groupId, int chanId, float x, boolean fromUpstream){return isEndChan(groupId, chanId) && checkEnd(chanId, x, fromUpstream);}
	public boolean isExchange(int groupId, int chanId, float x, boolean fromUpstream){return isExchangeChan(groupId, chanId) 
																						&& checkExchange(chanId, x, fromUpstream); }

	public int getGroupArrivals(int groupNumber){ return _groupArrivals.get(groupNumber);}
	public int getGroupLost(int groupNumber){ return _groupLost.get(groupNumber);}
	public boolean getDoSurvival(){return _doSurvival;}
	// x = 0 @ upstream node and x = length @ downstream node
	public boolean staReached(int chanId, float x, Map<Integer, Integer> staDist, boolean fromUpstream){
		Integer dist = staDist.get(chanId);
		if(dist == null)
			PTMUtil.systemExit("in calculating survival, couldn't find a channel distance for a station, check input, system exit.");
		int sign = fromUpstream? 1: -1;
		dist = sign*dist;
		x = sign*x;
		return !(x < dist);				
	}
	public void writeSurvivalRates(){
		try{
			BufferedWriter srWriter = PTMUtil.getOutputBuffer(_pathFileName);
			if(COMPLETEWRITEOUT){
				srWriter.write("Particles survived + lost at an end node are not necessary " 
						+"equal to particle arrived at the beginning node because a particle can be lost at a boundary "
						+"or wondering without reach an end node or an exchange node.  "
						+"All particles not detected at an end node or an exchange node are assumed lost.");
				srWriter.newLine();
				srWriter.write("Group ID".concat(",").concat("Station Name").concat(",")
						.concat("# of Particle Arrived").concat(",").concat("# of Particle Lost")
						.concat(",").concat(" # of Particle Survived").concat(",")
						.concat("Survival Rate not count missing"));
						//.concat(",").concat("Survival Rate missing as lost"));
				srWriter.newLine();
				//_ttHolder will never be null and there is at least one element
				// if no particle arrives to a group, this group will not appear in the write out file
				for (int id: _groupArrivals.keySet()){						
					Integer ar = _groupArrivals.get(id);
					Integer lost = _groupLost.get(id);
					Integer sur = _groupSurvival.get(id);
					if (ar == null){
						PTMUtil.systemExit("error in writing survival output.  this particle has never arrived at the starting node of this channel group");;
					}
					if (lost == null)
						lost = 0;
					if (sur == null)
						sur = 0;
					//TODO 
					//survival rate = sur/ar (not (1-lost/ar) ) is to be consistent with Russ' XT model. if fish is not detected at the end node, it assumes that it is lost.
					// not every fish arrived is detected at the end node.
					int tot = sur + lost;
					if (tot != 0){
						srWriter.write(Integer.toString(id).concat(",").concat(_groupName.get(id)).concat(",").concat(Integer.toString(ar)).concat(",").concat(Integer.toString(lost))
								.concat(",").concat(Integer.toString(sur)).concat(",")
								.concat(Float.toString(1.0f*sur/tot)));
								//.concat(",").concat(Float.toString(1.0f*sur/ar)));
						//TODO it is confusing to calculate the survival rate including those missing. so comment this part out.  
						/*
						 * Here is Adam's explanation why we calculate a survival rate only according to detected:
						 * When we fit the travel time model, we only use the particles that arrive at the end of a reach 
						 * and have a recorded travel time.  The particles that don't arrive (either because they take too 
						 * long and don't arrive by the end of the simulation or enter a different channel) are ignored in 
						 * fitting the travel time distribution.  The main reason for this is that the travel time data we have 
						 * are all, of course, from fish that have survived and migrated the specified reach successfully 
						 * (and whose tags have survived, meaning < 90 days).  However a byproduct of fitting this way is that 
						 * the behavioral parameters we use are only valid in describing the migration of particles which remain 
						 * in the channel and which complete the reach within 90 days.  Additionally, the survival parameters we 
						 * are using should be interpreted as being the cause of all mortality within a reach.  Thus, particles 
						 * which do not arrive at the end of a reach (and so do not have a travel time) should be removed from 
						 * survival calculations, rather than treated as additional mortality. The upshot of all of this is 
						 * that I believe we should be calculating survival as 
						 * (number of particles surviving at the end of the reach) 
						 * / (number of particles surviving at the end of the reach + number of particles arriving at the end of the reach but determined to have died).  
						 * 
						 * */
						srWriter.newLine();	
					}
				}
			}
			else{
				srWriter.write("Group ID".concat(",").concat("Station Name").concat(",").concat("Survival Rate"));
				srWriter.newLine();
				//_ttHolder will never be null and there is at least one element
				for (int id: _groupArrivals.keySet()){						
					Integer ar = _groupArrivals.get(id);
					Integer lost = _groupLost.get(id);
					Integer sur = _groupSurvival.get(id);
					if (ar == null){
						PTMUtil.systemExit("error in writing survival output.  this particle has never arrived at the starting node of this channel group");;
					}
					if (lost == null)
						lost = 0;
					if (sur == null)
						sur = 0;
					int tot = sur + lost;
					// if no particle reaches the end node, no survival rate should be considered.
					if (tot != 0){
						srWriter.write(Integer.toString(id).concat(",").concat(_groupName.get(id)).concat(",").concat(Float.toString(1.0f*sur/tot)));
						srWriter.newLine();
					}
				}
			}
			if(DEBUGWRITEOUT){
				srWriter.write("Particle ID".concat(",").concat("Group Id").concat(",").concat("Survival Rate"));
				srWriter.newLine();
				for (int parId: _pReachProb.keySet()){
					for (int gId: _pReachProb.get(parId).keySet()){
						srWriter.write(Integer.toString(parId).concat(",").concat(Integer.toString(gId)).concat(",")
							.concat(Double.toString(_pReachProb.get(parId).get(gId))));
						srWriter.newLine();
					}
				}
			}
			PTMUtil.closeBuffer(srWriter);
		}catch(IOException e){
			System.err.println("error occured when writing out survival rates!");
			e.printStackTrace();
		}
	}
	public void addArrivalToGroup(int groupNumber){
		addToGroup(groupNumber, _groupArrivals);
	}
	public void addSurvivalToGroup(int groupNumber){
		addToGroup(groupNumber, _groupSurvival);
	}
	public void addLostToGroup(int groupNumber){
		addToGroup(groupNumber, _groupLost);
	}
	public void minusArrivalToGroup(int groupNumber){
		minusToGroup(groupNumber, _groupArrivals);
	}
	public void minusSurvivalToGroup(int groupNumber){
		minusToGroup(groupNumber, _groupSurvival);
	}
	public void minusLostToGroup(int groupNumber){
		minusToGroup(groupNumber, _groupLost);
	}
	public SurvivalHelper getSurvivalHelper(){
		if(_survivalHelper == null)
			setSurvivalHelper();
		return _survivalHelper;
	}
	public Map<Integer, Map<Integer, Double>> getParticleSurvivalRates(){return _pReachProb;}
	public void addSurvivalRate(int pId, int groupId, double rate){
		if(!DEBUGWRITEOUT)
			return;
		Map<Integer, Double> reachSurvivals = _pReachProb.get(pId);
		if(reachSurvivals == null){
			reachSurvivals = new HashMap<Integer, Double>();
			_pReachProb.put(pId, reachSurvivals);
		}
		reachSurvivals.put(groupId, rate);
	}
	private void addToGroup(int groupNumber, Map<Integer, Integer> grp_arr_sur_lost){
		Integer i = grp_arr_sur_lost.get(groupNumber);
		if (i == null)
			grp_arr_sur_lost.put(groupNumber, 1);
		else
			grp_arr_sur_lost.put(groupNumber, ++i);
	}
	private void minusToGroup(int groupNumber, Map<Integer, Integer> grp_arr_sur_lost){
		Integer i = grp_arr_sur_lost.get(groupNumber);
		if (i == null)
			System.err.println("WARNING: cannot subtract 1 from the particle group, the list is empty!");
		else
			grp_arr_sur_lost.put(groupNumber, --i);
	}
	private void setSurvivalParameters(ArrayList<String> survivalParasIn){
		if (survivalParasIn == null){
			System.err.println("WARNING: No channel groups for suvival rates are defined in behavior input file!");
			return;
		}
		_pathFileName = PTMUtil.getPathFromLine(survivalParasIn.get(0), ':');
		int num_groups = PTMUtil.getIntFromLine(survivalParasIn.get(1), "NUMBER_OF_SURVIVAL_CALCULATION_GROUP");
		for (int i=1; i<num_groups+1; i++){
			ArrayList<String> survivalStrs = PTMUtil.getInputBlock(survivalParasIn, "GROUP_"+i, "END_GROUP_"+i);
			if(survivalStrs.size() != 6)
				PTMUtil.systemExit("errors in the survival parameter input line group:"+i);
			String name = PTMUtil.getPathFromLine(survivalStrs.get(0), ':');
			//stSta only has one pair, but enStas and exStas can have many pairs.
			ArrayList<int[]> stStas = PTMUtil.getIntPairsFromLine(survivalStrs.get(1), "START_STATION");
			ArrayList<int[]> enStas = PTMUtil.getIntPairsFromLine(survivalStrs.get(2), "END_STATION");
			ArrayList<int[]> exStas = null;
			//exchangeable start station often empty
			//TODO clean up no need to give warning
			/*
			if (survivalStrs.get(3).split(":").length < 2)
				System.err.println("Warning: EXCHANGEABLE_START_STATION line is empty!");
			else
			*/
			if (survivalStrs.get(3).split(":").length >= 2)
				exStas = PTMUtil.getIntPairsFromLine(survivalStrs.get(3), "EXCHANGEABLE_START_STATION");
			ArrayList<Integer> enStasInt = new ArrayList<Integer>();
			ArrayList<Integer> exStasInt = new ArrayList<Integer>();
			//External channel numbers are converted to internal channel numbers
			for(int[] stSt: stStas){
				int stStaInternal = PTMHydroInput.getIntFromExtChan(stSt[0]);
				_startStas.add(stStaInternal);
				_startStasDist.put(stStaInternal,stSt[1]);
				_startStaGroup.put(stStaInternal,i);
			}
			for(int[] enst: enStas){
				int enSta = PTMHydroInput.getIntFromExtChan(enst[0]);
				_endStasDist.put(enSta,enst[1]);
				enStasInt.add(enSta);
			}
			if (exStas != null){
				for(int[] exst: exStas){
					int exSta = PTMHydroInput.getIntFromExtChan(exst[0]);
					_exchStasDist.put(exSta,exst[1]);
					exStasInt.add(exSta);
				}
			}
			_groupName.put(i, name);
			//Java pass by reference. changing enStasInt and exStasInt will change the maps.
			//so don't change them once they are put into the maps unless you rewrite code here to make the map immutable 
			_groupEndStas.put(i,enStasInt);
			_groupExchStas.put(i,exStasInt);
			String [] paraTitle = {"LAMBDA","OMEGA","X"};
			if(!PTMUtil.check(survivalStrs.get(4).split("[,:\\s\\t]+"), paraTitle))
				PTMUtil.systemExit("wrong survival input line:"+survivalStrs.get(4));
			ArrayList<Double> paras = PTMUtil.getDoubles(survivalStrs.get(5));
			_groupParas.put(i, paras);						
		}
	}
	private void setSurvivalHelper(){
		if (_fishType.equalsIgnoreCase("SALMON")){
			_survivalHelper = new SalmonSurvivalHelper(new SalmonBasicSurvivalBehavior(this));
			System.out.println("Created Particle Salmon Survival Helper");
		}
		else
			PTMUtil.systemExit("don't know how to deal the fish species: "+_fishType+", system exit.");
	}
	private String _pathFileName = null;
	// <start station chan#> start chan# is unique for each Calculation Group
	private ArrayList<Integer> _startStas=null;
	// <start station chan#, start station distance> start chan# is unique for each Calculation Group
	private Map<Integer, Integer> _startStasDist=null;
	// <end station chan#, end station distance> 
	private Map<Integer, Integer> _endStasDist=null;
	// <exchangeable station chan#, exchangeable station distance> 
	private Map<Integer, Integer> _exchStasDist=null;
	// <group#, end station chan# list> group# is unique for each Calculation Group
	private Map<Integer, ArrayList<Integer>> _groupEndStas=null;
	// <group#, exchangeable station chan# list> group# is unique for each Calculation Group
	private Map<Integer, ArrayList<Integer>> _groupExchStas=null;
	// <group#, survival parameters lambda, omega, x list> group# is unique for each Calculation Group
	private Map<Integer, ArrayList<Double>> _groupParas=null;
	// <group#, # of particles arrived in the reach group> group# is unique for each Calculation Group
	private Map<Integer, Integer> _groupArrivals=null;
	// <group#, # of particles survived in the reach group> group# is unique for each Calculation Group
	private Map<Integer, Integer> _groupSurvival=null;
	// <group#, group name> group# is unique for each Calculation Group
	private Map<Integer, String> _groupName=null;	
	// <group#, # of particles dead in the reach group> group# is unique for each Calculation Group
	private Map<Integer, Integer> _groupLost=null;
	// <start station chan#, survival calculation group number> 
	private Map<Integer,Integer> _startStaGroup = null;
	//for output survival rate for each particle for each group
	//Map<pid, Map<group#, survival probability>>
	private Map<Integer, Map<Integer, Double>> _pReachProb = null;
	private boolean _doSurvival = true;
	private SurvivalHelper _survivalHelper = null;
	private String _fishType = null;
	private boolean DEBUG = false;
	private boolean DEBUGWRITEOUT = false;
	private boolean COMPLETEWRITEOUT = true;
}
