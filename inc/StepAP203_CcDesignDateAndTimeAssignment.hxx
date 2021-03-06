// This file is generated by WOK (CPPExt).
// Please do not edit this file; modify original file instead.
// The copyright and license terms as defined for the original file apply to 
// this header file considered to be the "object code" form of the original source.

#ifndef _StepAP203_CcDesignDateAndTimeAssignment_HeaderFile
#define _StepAP203_CcDesignDateAndTimeAssignment_HeaderFile

#include <Standard.hxx>
#include <Standard_DefineHandle.hxx>
#include <Handle_StepAP203_CcDesignDateAndTimeAssignment.hxx>

#include <Handle_StepAP203_HArray1OfDateTimeItem.hxx>
#include <StepBasic_DateAndTimeAssignment.hxx>
#include <Handle_StepBasic_DateAndTime.hxx>
#include <Handle_StepBasic_DateTimeRole.hxx>
class StepAP203_HArray1OfDateTimeItem;
class StepBasic_DateAndTime;
class StepBasic_DateTimeRole;


//! Representation of STEP entity CcDesignDateAndTimeAssignment
class StepAP203_CcDesignDateAndTimeAssignment : public StepBasic_DateAndTimeAssignment
{

public:

  
  //! Empty constructor
  Standard_EXPORT StepAP203_CcDesignDateAndTimeAssignment();
  
  //! Initialize all fields (own and inherited)
  Standard_EXPORT   void Init (const Handle(StepBasic_DateAndTime)& aDateAndTimeAssignment_AssignedDateAndTime, const Handle(StepBasic_DateTimeRole)& aDateAndTimeAssignment_Role, const Handle(StepAP203_HArray1OfDateTimeItem)& aItems) ;
  
  //! Returns field Items
  Standard_EXPORT   Handle(StepAP203_HArray1OfDateTimeItem) Items()  const;
  
  //! Set field Items
  Standard_EXPORT   void SetItems (const Handle(StepAP203_HArray1OfDateTimeItem)& Items) ;




  DEFINE_STANDARD_RTTI(StepAP203_CcDesignDateAndTimeAssignment)

protected:




private: 


  Handle(StepAP203_HArray1OfDateTimeItem) theItems;


};







#endif // _StepAP203_CcDesignDateAndTimeAssignment_HeaderFile
