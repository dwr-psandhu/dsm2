#ifndef oprule_rule_OPERATIONACTION_H__INCLUDED_
#define oprule_rule_OPERATIONACTION_H__INCLUDED_

#include<deque>
#include "assert.h"
#include<iostream>


namespace oprule {
namespace rule {

/** Abstract base class for all actions
 * Interface for all actions. This base class contains mostly pure
 * virtual methods.
 */
class OperationAction 
{
protected:
   OperationAction() : _parent(0){}

public:
   /** Advance the action in time */
	virtual void advance(double dt) = 0;

   /** Assess whether the action is applicable 
     * (physically sensible) 
     * in current model context. 
     * todo: do we need this?
   */
    virtual bool isApplicable(){return true;}

   /** Activate the action */
   virtual void setActive(bool active) = 0;


   virtual void step(double dt){};

   /** Test if the action is active.
   * @return true if the action is in progress.
   */
   virtual bool isActive() { return false; }

   /** Perform actions on completion on completion of action
   * Context dependent. Performs any wrapup activity.
   */
   virtual void onCompletion(){ 
      if (_parent){
        _parent->childComplete();
      } 
   };


   /**Test if this action is a compound collection of sub actions.
    * @return true if the action has subactions
    */
   virtual bool hasSubActions(){ 
      return false; 
   }


   /** Test if this action directly manipulates the model 
    * @return true if the action directly manipulates the model.
    */
   virtual bool isModelStateAction(){
      return !hasSubActions();
   }

   /** Register a parent (if action is added to a collection)
   * Registration is carried out when assembling actions into collections. Refer
   * to collections for examples.
   */
   void registerParent(OperationAction* parent){
      if (_parent) throw std::domain_error("Parent already registered");
      _parent=parent;
   }
   
   /**
    * Used if this action is a container, this method
    * is the mechanism for children to inform the parent container that
    * the child action is complete. The default implementation just
    * ensures that the method is only called when an action is a
    * a container.
    */
   virtual void childComplete(){assert(hasSubActions());};

   /** Compare with another action
     * Test true if this actions has an effect that overlaps
     * with that of the other. 
   */
   virtual bool overlaps( const OperationAction& otherAction ){ 
      std::cout << "Base overlaps" << std::endl;
      return false; //this default will work when the action 
                    //is not a model action (e.g. it is a collection)
                    //or when two different state types are involved
   }

   /** Type of collection used for lists of subactions */
   typedef std::deque<OperationAction*> ActionListType;

   /** Create an exhaustive (but not carefully ordered)
    * list of all actions in an operating rule. The current action will
    * either append itself to the list or (if it is a compound action) 
    * request its subactions to do so
    * @todo: is this not done?
    */
   virtual void appendToActionList(
      OperationAction::ActionListType& listToConstruct){
      //std::cout << "Subactions: " << this->hasSubActions()<<std::endl;
      if (this->hasSubActions()){
         //std::cout << " identified subactions" <<std::endl;
         /**@todo: critical to finish this*/
      }else{
         listToConstruct.push_back(this);
      }
   }

protected: 
   /** 
    * Get the parent of this action assuming the action is in a collection.
    *@return The parent (collection) holding this action.
    *@todo: what if not member of a collection?
   */
   OperationAction* parent(){ return _parent;}

private:
   OperationAction* _parent;

};
}}     //namespace
#endif // include guard