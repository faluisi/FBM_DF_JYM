pageextension 61506 FBM_SInvSubExt_DF extends "Sales Invoice Subform"
{
    layout
    {
        modify("Period Start")
        {
            Visible = false;

        }
        modify("Period End")
        {
            Visible = false;
        }
        modify("FBM_Period Start")
        {
            trigger
                OnAfterValidate()
            begin
                rec."Period Start" := rec."FBM_Period Start"
            end;
        }
        modify("FBM_Period End")
        {
            trigger
                OnAfterValidate()
            begin
                rec."Period End" := rec."FBM_Period End"
            end;
        }




    }

}